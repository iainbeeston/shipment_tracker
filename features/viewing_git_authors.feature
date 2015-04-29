Feature: Viewing Git Authors
  As a product owner I can view the authors between 2 software versions

Scenario: View Git Authors from beginning of tree
  Given a repository called "Manhattan"
  And a commit by "Bob" is created
  And a commit by "Jane" is created
  When I compare the beginning with the last commit for "Manhattan"
  Then I should see the authors "Bob" and "Jane"

Scenario: View Git Authors through a section of tree
  Given a repository called "Manhattan"
  And a commit by "Alice" is created
  And a commit by "Bob" is created
  And a commit by "Collin" is created
  And a commit by "David" is created
  And a commit by "Edgar" is created
  When I compare the second commit with the fourth commit for "Manhattan"
  Then I should see the authors "Collin" and "David"

Scenario: Attempting to view authors when a commit does not exist
  Given a repository called "Manhattan"
  And a commit by "Alice" is created
  And a commit by "Bob" is created
  When I compare the commit "178740d166c13c76ffd90d78366d93e8b56abb97" with the second commit for "Manhattan"
  Then I should see the error "Commit '178740d166c13c76ffd90d78366d93e8b56abb97' could not be found in Manhattan"

Scenario: Attempting to view authors when a commit is not valid
  Given a repository called "Manhattan"
  And a commit by "Alice" is created
  And a commit by "Bob" is created
  When I compare the commit "INVALID !!!" with the second commit for "Manhattan"
  Then I should see the error "Commit 'INVALID !!!' is not valid"