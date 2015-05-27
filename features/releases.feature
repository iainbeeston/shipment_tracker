Feature: Viewing Releases
  As a deployer and an auditor I want to view all releases for a given application

Scenario: Viewing releases for an app
  Given an application called "frontend"
  And a commit "#1" with message "first commit" is created at "2015-05-27 14:01:17 UTC"
  And a commit "#2" with message "second commit" is created at "2015-05-27 15:04:19 UTC"

  When I view the releases for "frontend"

  Then I should see the releases
    | id | date                    | message       |
    | #2 | 2015-05-27 15:04:19 UTC | second commit |
    | #1 | 2015-05-27 14:01:17 UTC | first commit  |
