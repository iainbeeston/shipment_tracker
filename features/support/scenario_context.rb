require 'support/git_test_repository'
require 'repository_location'

require 'rack/test'
require 'factory_girl'

module Support
  class ScenarioContext
    include Rack::Test::Methods

    def initialize(app)
      @app = app
    end

    def setup_application(name)
      dir = Dir.mktmpdir

      @application = name

      @repos ||= {}
      @repos[name] = Support::GitTestRepository.new(dir)

      @tickets = {}

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

    def create_and_start_ticket(key:, summary:)
      ticket_details = { key: key, summary: summary }
      @tickets[key] = ticket_details

      [:to_do, :in_progress].each do |status|
        event = build(:jira_event, status, ticket_details)
        post_json '/events/jira', event.details
      end
    end

    def approve_ticket(jira_key, approver_email:, time:)
      ticket_details = @tickets.fetch(jira_key)
      event = build(:jira_event, :done, ticket_details.merge(
                                          user_email: approver_email,
                                          updated: time,
      ))
      post_json '/events/jira', event.details
    end

    private

    attr_reader :app

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
      @scenario_context ||= ScenarioContext.new(app)
    end
  end
end

World(Support::ScenarioContextHelpers)
