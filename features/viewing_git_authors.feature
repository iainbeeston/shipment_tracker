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
  When I compare the second commit with the fourth commit for "Manhattan"
  Then I should see the authors "Collin" and "David"
