Feature: Viewing Feature Audit
  As a product owner I can view what went in between 2 versions

Scenario: Viewing information between 2 versions
  Given an application called "project1"
  And these tickets are created
    | key      | summary      |
    | JIRA-123 | Ticket zero  |
    | JIRA-456 | Ticket one   |
    | JIRA-789 | Ticket two   |
    | JIRA-814 | Ticket three |
  And a commit "#1" by "Alice" is created with message "JIRA-123 Change copy"
  And "project1" was deployed
    | server                   | deployed_at      | deployed_by |
    | pub1.fundingcircle.co.uk | 2014-03-20 19:03 | Alice       |
    | pub2.fundingcircle.co.uk | 2014-03-20 19:04 | Alice       |
  And a commit "#2" by "Collin" is created with message "JIRA-456 Fix repayments"
  And a failing CircleCi build for "#2"
  And a commit "#3" by "David" is created with message "Add autolend feature JIRA-789"
  And a passing CircleCi build for "#3"
  And a passing Jenkins build for "#3"
  And "project1" was deployed
    | server             | deployed_at      | deployed_by |
    | galaga.fcuat.co.uk | 2014-03-20 21:10 | Alice       |
  And a commit "#4" by "Edgar" is created with message "Fix typo JIRA-814 Closes #123"

  When I compare the first commit with the fourth commit for "project1"

  Then I should only see the authors "Collin, David and Edgar"
  And the tickets
    | key      | summary      |
    | JIRA-456 | Ticket one   |
    | JIRA-789 | Ticket two   |
    | JIRA-814 | Ticket three |
  And the builds
    | source   | status  | commit |
    | CircleCi | success | #3     |
    | Jenkins  | success | #3     |
    | CircleCi | failed  | #2     |
  And the deploys
    | server             | deployed_at      | deployed_by | commit |
    | galaga.fcuat.co.uk | 2014-03-20 21:10 | Alice       | #3     |

@wip
Scenario: For application that does not exist

Scenario: Viewing information from beginning of time
  Given an application called "project2"
  And a commit "#1" by "Bob" is created
  And a commit "#2" by "Jane" is created
  When I compare the beginning with the last commit for "project2"
  Then I should only see the authors "Bob and Jane"

Scenario: Viewing information between a version that does not exist
  Given an application called "project3"
  And a commit "#1" by "Alice" is created
  And a commit "#2" by "Bob" is created
  When I compare the commit "178740d166c13c76ffd90d78366d93e8b56abb97" with the second commit for "project3"
  Then I should see the error "Commit '178740d166c13c76ffd90d78366d93e8b56abb97' could not be found in project3"

Scenario: Viewing information for a version that is invalid
  Given an application called "project4"
  And a commit "#1" by "Alice" is created
  And a commit "#2" by "Bob" is created
  When I compare the commit "INVALID !!!" with the second commit for "project4"
  Then I should see the error "Commit 'INVALID !!!' is not valid"
