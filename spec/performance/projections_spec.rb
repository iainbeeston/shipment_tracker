require 'rails_helper'
require 'support/git_test_repository'
require 'support/repository_builder'

require 'benchmark'
require 'fileutils'
require 'csv'

RSpec.describe 'Projection performance', type: :request do
  before(:all) do
    login_with_omniauth
  end

  def create_events(count)
    number = (count / 6).to_i

    build_events(type: :jira_event, number: number, key: 'JIRA-$ID')
    build_events(type: :circle_ci_event, number: number)
    build_events(type: :jenkins_event, number: number)
    build_events(type: :deploy_event, number: number)
    build_events(type: :manual_test_event, number: number)
    build_events(type: :uat_event, number: number)
  end

  def drop_events
    Event.delete_all
  end

  def create_snapshots
    Repositories::FeatureReviewRepository.new.update
  end

  def drop_snapshots
    Snapshots::FeatureReview.delete_all
    Snapshots::EventCount.delete_all
  end

  def benchmark(count, &block)
    create_events(count)

    time_to_run = Benchmark.realtime(&block)
    results = [Event.count, time_to_run]
    puts "#{results[0]} events -> #{results[1].round(3)} seconds"

    drop_events

    results
  end

  def benchmark_with_snapshots(count, &block)
    create_events(count)
    create_snapshots

    time_to_run = Benchmark.realtime(&block)
    results = [Event.count, time_to_run]
    puts "#{results[0]} events -> #{results[1].round(3)} seconds"

    drop_events
    drop_snapshots

    results
  end

  def csv(name:, headers:, &block)
    filename = Rails.root.join('performance', "#{name}.csv")
    FileUtils.mkdir_p File.dirname(filename)
    CSV.open(filename, 'wb') do |csv_contents|
      csv_contents << headers
      block.call(csv_contents)
    end
  end

  def progression(start: 10_000, points: 10, factor: 2, &block)
    (points - 1).times.reduce([start]) { |a, _e| a << a.last * factor }.each do |count|
      block.call(count)
    end
  end

  describe 'Feature Review' do
    let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }
    let(:server) { 'uat.fc.com' }
    let(:feature_review_url) { Support::FeatureReviewUrl.build(apps, server) }
    let(:feature_review_path) { URI.parse(feature_review_url).request_uri }

    it 'measures the request time' do
      csv(name: 'feature_review', headers: ['Count', 'Time to Run']) do |file|
        progression do |event_count|
          create :jira_event, comment_body: "Here you go: #{feature_review_url}"
          create :circle_ci_event, version: apps['frontend']
          apps.each do |name, version|
            create :deploy_event, server: server, app_name: name, version: version
          end
          create :manual_test_event, apps: apps
          create :uat_event, server: server

          file << benchmark(event_count) do
            get(feature_review_path)
          end
        end
      end
    end
  end

  describe 'Feature Review Search' do
    let(:apps) { { 'frontend' => version, 'backend' => 'def' } }
    let(:server) { 'uat.fc.com' }
    let(:feature_review_url) { Support::FeatureReviewUrl.build(apps, server) }

    let(:repo_name) { 'frontend' }
    let(:test_git_repo) { Support::GitTestRepository.new }
    let(:repository_builder) { Support::RepositoryBuilder.new(test_git_repo) }

    before do
      repository_builder.build(git_diagram)
      RepositoryLocation.create(name: repo_name, uri: "file://#{test_git_repo.dir}")
    end

    # rubocop:disable Style/BlockDelimiters
    context 'with a simple repo so that git has minimal effect on performance' do
      let(:git_diagram) { '-A' }
      let(:version) { test_git_repo.commit_for_pretend_version('A') }

      context 'without snapshots' do
        it 'measures the request time' do
          csv(name: 'feature_review_search', headers: ['Count', 'Time to Run']) do |file|
            progression do |event_count|
              create :jira_event, comment_body: "Here you go: #{feature_review_url}"

              file << benchmark(event_count) do
                get(search_feature_reviews_path, application: 'frontend', version: version)
              end
            end
          end
        end
      end

      context 'with snapshots' do
        it 'measures the request time' do
          csv(name: 'feature_review_search_with_snapshots', headers: ['Count', 'Time to Run']) do |file|
            progression do |event_count|
              create :jira_event, comment_body: "Here you go: #{feature_review_url}"

              file << benchmark_with_snapshots(event_count) do
                get(search_feature_reviews_path, application: 'frontend', version: version)
              end
            end
          end
        end
      end
    end
    # rubocop:enable Style/BlockDelimiters
  end

  describe 'Releases' do
    let(:repo_name) { 'repo' }
    let(:test_git_repo) { Support::GitTestRepository.new }
    let(:repository_builder) { Support::RepositoryBuilder.new(test_git_repo) }

    let(:git_diagram) do
      <<-'EOS'
           o-A-B
          /     \
        -o---o---C---o
      EOS
    end

    before do
      RepositoryLocation.create(name: repo_name, uri: "file://#{test_git_repo.dir}")
      puts test_git_repo.dir
    end

    def add_branches(count)
      count.times do
        repository_builder.build(git_diagram)
        version = test_git_repo.commit_for_pretend_version('B')
        feature_review_url = Support::FeatureReviewUrl.build(frontend: version)
        create :jira_event, comment_body: "Here you go: #{feature_review_url}"
      end
    end

    it 'measures the request time' do
      points = 90
      increment = 50
      csv(name: 'releases', headers: ['Commit Count', 'Event Count', 'Time to Run']) do |file|
        points.times do
          add_branches(increment)

          time = Benchmark.realtime do
            get(release_path(repo_name))
          end

          results = [test_git_repo.total_commits, Event.count, time]
          file << results
          puts results.inspect
        end
      end
    end
  end

  private

  def build_events(type:, number:, **args)
    blueprint = build(type, args)
    Event.connection.execute(<<-QUERY)
      INSERT INTO events (
          details,
          created_at,
          updated_at,
          type
        )
        SELECT json (replace('#{blueprint.details.to_json}', '$ID', ids.id::text)),
               now(),
               now(),
               '#{blueprint.type}'
        FROM (SELECT generate_series(1, #{number}) AS id) AS ids;
    QUERY
  end
end
