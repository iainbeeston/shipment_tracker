Feature: Issue Audit
  As a product owner I can view activity for an issue

Scenario: Viewing activity for an issue
  Given an application called "hello_world_rails"
  And a ticket "JIRA-123" with summary "Urgent ticket" is started
  And a ticket "JIRA-999" with summary "New ticket" is started
  And ticket "JIRA-123" is approved by "eve@fundingcircle.com" at "2015-06-07T15:24:34.957+0100"

  When I view activity for issue "JIRA-123"

  Then I should only see the ticket
    | key      | summary       | status | approver email        | approved at             |
    | JIRA-123 | Urgent ticket | Done   | eve@fundingcircle.com | 2015-06-07 14:24:34 UTC |