Feature: Viewing Releases
  As a deployer and an auditor I want to view all releases for a given application

Scenario: Viewing releases for an app
  Given an application called "frontend"
  And a commit "#1" with message "first commit" is created
  And a commit "#2" with message "second commit" is created

  When I view the releases for "frontend"

  Then I should see the releases
    | message       |
    | second commit |
    | first commit  |
