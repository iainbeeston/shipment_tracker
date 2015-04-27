Feature: Viewing Git Authors
  As a product owner I can view the authors between 2 software versions

Scenario: View Git Authors
  Given a repository
  And a commit by "Bob" is created
  And a commit by "Jane" is created
  When I compare the first commit with the last commit
  Then I should see the authors "Bob" and "Jane"
