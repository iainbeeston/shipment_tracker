require 'support/git_test_repository'
require 'repository_location'

require 'rack/test'
require 'factory_girl'

module Support
  class ScenarioContext
    def initialize(app, host)
      @app = app # used by rack-test
      @host = host
      @application = nil
      @repos = {}
      @tickets = {}
      @review_url = nil
    end

    def setup_application(name)
      dir = Dir.mktmpdir

      @application = name
      @repos[name] = Support::GitTestRepository.new(dir)

      RepositoryLocation.create(uri: "file://#{dir}", name: name)
    end

    def repository_for(application)
      @repos[application]
    end

    def resolve_app(version)
      app_for_version(resolve_version(version))
    end

    def resolve_version(version)
      version.start_with?('#') ? commit_from_pretend(version) : version
    end

    def last_repository
      @repos[last_application]
    end

    def last_application
      @application
    end

    def create_and_start_ticket(key:, summary:, description: nil)
      ticket_details1 = { key: key, summary: summary, description: description, status: 'To Do' }
      ticket_details2 = ticket_details1.merge(status: 'In Progress')

      [ticket_details1, ticket_details2].each do |ticket_details|
        event = build(:jira_event, ticket_details)
        post_json '/events/jira', event.details

        @tickets[key] = ticket_details
      end
    end

    def prepare_review(apps, uat_url)
      apps_hash = {}
      apps.each do |app|
        apps_hash[app[:app_name]] = resolve_version(app[:version])
      end

      @review_url = host.merge("/feature_reviews?#{{ apps: apps_hash, uat_url: uat_url }.to_query}").to_s
    end

    def link_ticket(jira_key)
      ticket_details = @tickets.fetch(jira_key)
      event = build(:jira_event, ticket_details.merge(comment_body: "Here you go: #{review_url}"))
      post_json '/events/jira', event.details
    end

    def approve_ticket(jira_key, approver_email:, time:)
      ticket_details = @tickets.fetch(jira_key).except(:status)
      event = build(:jira_event, :done, ticket_details.merge(
                                          user_email: approver_email,
                                          updated: time,
      ))
      post_json '/events/jira', event.details
    end

    def review_url
      fail 'Review url not set' unless @review_url
      @review_url
    end

    private

    attr_reader :app

    include Rack::Test::Methods

    def host
      URI.parse(@host)
    end

    def commit_from_pretend(pretend_commit)
      value = @repos.values.map { |r| r.commit_for_pretend_version(pretend_commit) }.compact.first
      fail "Could not find '#{pretend_commit}'" unless value
      value
    end

    def app_for_version(version)
      @repos.find { |_app_name, repo| repo.commits.map(&:version).include?(version) }.first
    end

    def build(*args)
      FactoryGirl.build(*args)
    end
  end

  module ScenarioContextHelpers
    def scenario_context
      @scenario_context ||= ScenarioContext.new(app, Capybara.default_host)
    end
  end
end

World(Support::ScenarioContextHelpers)
