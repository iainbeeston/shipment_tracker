Feature: Issue Audit
  As a product owner I can view activity across all repositories for a JIRA ticket

Scenario: Viewing activity for an issue
  Given an application called "frontend"
  And an application called "backend"
  And an application called "irrelevant"
  And a ticket "JIRA-123" with summary "New functionality for frontend and backend" is started 
  And a commit "#f1" by "Billy" is created for ticket "JIRA-123" for "frontend"
  And CircleCi "passes" for commit "#f1"
  And a commit "#f2" by "Ed" is created for ticket "JIRA-123" for "frontend"
  And CircleCi "fails" for commit "#f2"
  And CircleCi "passes" for commit "#f2"
  And a commit "#b1" by "Alice" is created for ticket "JIRA-123" for "backend"
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
