Feature: Viewing Feature Audit
  As a product owner I can view what went in between 2 versions

Scenario: Viewing information between 2 versions
  Given an application called "application1"
  And a ticket "JIRA-123" with summary "Urgent ticket" is started
  And a ticket "JIRA-999" with summary "New ticket" is started
  And a commit "#1" by "Alice" is created for ticket "JIRA-123"
  And a commit "#2" by "Billy" is created for ticket "JIRA-123"
  And CircleCi "passes" for commit "#2"
  And ticket "JIRA-123" is approved by "eve@fundingcircle.com" at "2015-06-07T15:24:34.957+0100"
  And commit "#2" is deployed by "Frank" on server "example.com"

  When I compare commit "#1" with commit "#2" for "application1"

  Then I should only see the authors
    | author |
    | Billy  |
  And the tickets
    | key      | summary       | description | status | approver email        | approved at             |
    | JIRA-123 | Urgent ticket |             | Done   | eve@fundingcircle.com | 2015-06-07 14:24:34 UTC |
  And the builds
    | source   | status  | commit |
    | CircleCi | success | #2     |
  And the deploys
    | server      | deployed_by | commit |
    | example.com | Frank       | #2     |

@wip
Scenario: For application that does not exist

Scenario: Viewing information between a version that does not exist
  Given an application called "application2"
  And a commit "#1" by "Alice" is created
  And a commit "#2" by "Bob" is created

  When I compare commit "178740d166c13c76ffd90d78366d93e8b56abb97" with commit "#2" for "application2"

  Then I should see the error "Commit '178740d166c13c76ffd90d78366d93e8b56abb97' could not be found in application2"

Scenario: Viewing information for a version that is invalid
  Given an application called "application3"
  And a commit "#1" by "Alice" is created
  And a commit "#2" by "Bob" is created

  When I compare commit "INVALID !!!" with commit "#2" for "application3"

  Then I should see the error "Commit 'INVALID !!!' is not valid"
