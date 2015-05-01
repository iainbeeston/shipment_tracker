Feature: Viewing Feature Audit
  As a product owner I can view what went in between 2 versions

Scenario: Viewing information between 2 versions
  Given an application called "proj1"
  And a commit "#1" by "Alice" is created
  And "proj1" was deployed
    | server                   | deployed_at      | deployed_by |
    | pub1.fundingcircle.co.uk | 2014-03-20 19:03 | Alice       |
    | pub2.fundingcircle.co.uk | 2014-03-20 19:04 | Alice       |
  And a commit "#2" by "Collin" is created
  And a commit "#3" by "David" is created
  And "proj1" was deployed
    | server             | deployed_at      | deployed_by |
    | galaga.fcuat.co.uk | 2014-03-20 21:10 | Alice       |
  And a commit "#4" by "Edgar" is created

  When I compare the first commit with the fourth commit for "proj1"

  Then I should only see the authors Collin, David and Edgar 
  And I should only see the deploys
    | server             | deployed_at      | deployed_by | commit |
    | galaga.fcuat.co.uk | 2014-03-20 21:10 | Alice       | #3     |

@wip
Scenario: For application that does not exist

Scenario: Viewing information from beginning of time
  Given an application called "proj2"
  And a commit "#1" by "Bob" is created
  And a commit "#2" by "Jane" is created
  When I compare the beginning with the last commit for "proj2"
  Then I should only see the authors Bob and Jane

Scenario: Viewing information between a version that does not exist
  Given an application called "proj3"
  And a commit "#1" by "Alice" is created
  And a commit "#2" by "Bob" is created
  When I compare the commit "178740d166c13c76ffd90d78366d93e8b56abb97" with the second commit for "proj3"
  Then I should see the error "Commit '178740d166c13c76ffd90d78366d93e8b56abb97' could not be found in proj3"

Scenario: Viewing information for a version that is invalid
  Given an application called "proj4"
  And a commit "#1" by "Alice" is created
  And a commit "#2" by "Bob" is created
  When I compare the commit "INVALID !!!" with the second commit for "proj4"
  Then I should see the error "Commit 'INVALID !!!' is not valid"
