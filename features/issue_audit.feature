Feature: Issue Audit
  As a product owner I can view activity across all repositories for a JIRA ticket

Scenario: Viewing activity for an issue
  Given an application called "hello_world_rails"
  And a ticket "JIRA-123" with summary "Urgent ticket" is started
  And a ticket "JIRA-999" with summary "New ticket" is started
  And a commit "#1" by "Alice" is created for ticket "JIRA-123" for "hello_world_rails"
  And a commit "#2" by "Billy" is created on branch "master" for ticket "JIRA-999" for "hello_world_rails"
  And a commit "#3" by "Carol" is created on branch "foo" for ticket "JIRA-123" for "hello_world_rails"
  And a commit "#4" by "David" is created on branch "foo" for ticket "JIRA-123" for "hello_world_rails"
  And a commit "#5" by "Eve" is created on branch "foo" for ticket "JIRA-999" for "hello_world_rails"
  And CircleCi "passes" for commit "#1"
  And CircleCi "passes" for commit "#2"
  And CircleCi "passes" for commit "#3"
  And CircleCi "fails" for commit "#4"
  # Flaky test, build retriggered
  And CircleCi "passes" for commit "#4"
  And CircleCi "passes" for commit "#5"
  And ticket "JIRA-123" is approved by "frank@fundingcircle.com" at "2015-06-07T15:24:34.957+0100"

  When I view activity for issue "JIRA-123"

  Then I should only see the ticket
    | key      | summary       | status | approver email          | approved at             |
    | JIRA-123 | Urgent ticket | Done   | frank@fundingcircle.com | 2015-06-07 14:24:34 UTC |
  And the authors for "hello_world_rails"
    | author |
    | Carol  |
    | David  |
  And the builds for "hello_world_rails"
    | source   | status  | commit |
    | CircleCi | failed  | #4     |
    | CircleCi | success | #4     |

Scenario: Viewing activity for an issue on multiple applications
  Given an application called "frontend"
  And an application called "backend"
  And an application called "irrelevant"
  And a ticket "JIRA-123" with summary "New functionality for frontend and backend" is started
  And a commit "#f0" by "Alice" is created for ticket "JIRA-123" for "frontend"
  And a commit "#f1" by "Billy" is created on branch "foo" for ticket "JIRA-123" for "frontend"
  And CircleCi "passes" for commit "#f1"
  And a commit "#f2" by "Ed" is created on branch "foo" for ticket "JIRA-123" for "frontend"
  And CircleCi "fails" for commit "#f2"
  And CircleCi "passes" for commit "#f2"
  And a commit "#b0" by "Alice" is created for ticket "JIRA-123" for "backend"
  And a commit "#b1" by "Alice" is created on branch "foo" for ticket "JIRA-123" for "backend"
  And CircleCi "fails" for commit "#b1"

  When I view activity for issue "JIRA-123"

  Then I should only see the ticket
    | key      | summary                                    | status      | approver email | approved at |
    | JIRA-123 | New functionality for frontend and backend | In Progress |                |             |
  And I should only see the applications
    | application |
    | frontend    |
    | backend     |
  And the authors for "frontend"
    | author |
    | Billy  |
    | Ed     |
  And the builds for "frontend"
    | source   | status  | commit |
    | CircleCi | failed  | #f2    |
    | CircleCi | success | #f2    |
  And the authors for "backend"
    | author |
    | Alice  |
  And the builds for "backend"
    | source   | status  | commit |
    | CircleCi | failed  | #b1    |
