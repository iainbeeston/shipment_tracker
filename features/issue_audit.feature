Feature: Issue Audit
  As a product owner I can view activity for an issue

Scenario: Viewing activity for an issue
  Given an application called "hello_world_rails"
  And a ticket "JIRA-123" with summary "Urgent ticket" is started
  And a ticket "JIRA-999" with summary "New ticket" is started
  And a commit "#1" by "Alice" is created for ticket "JIRA-123"
  And a commit "#2" by "Billy" is created for ticket "JIRA-123"
  And a commit "#3" by "Carol" is created for ticket "JIRA-999"
  And CircleCi "passes" for commit "#1"
  And CircleCi "fails" for commit "#2"
  # Flaky test, build retriggered
  And CircleCi "passes" for commit "#2"
  And ticket "JIRA-123" is approved by "eve@fundingcircle.com" at "2015-06-07T15:24:34.957+0100"

  When I view activity for issue "JIRA-123"

  Then I should only see the ticket
    | key      | summary       | status | approver email        | approved at             |
    | JIRA-123 | Urgent ticket | Done   | eve@fundingcircle.com | 2015-06-07 14:24:34 UTC |
  And the authors
    | author |
    | Alice  |
    | Billy  |
  And the builds
    | source   | status  | commit |
    | CircleCi | failed  | #2     |
    | CircleCi | success | #2     |