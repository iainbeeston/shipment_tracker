Feature: Viewing Releases
  As a deployer and an auditor I want to view all releases for a given application

Scenario: Viewing releases for an app
  Given an application called "frontend"
  And a ticket "JIRA-123" with summary "Urgent ticket" and description "Urgent stuff" is started
  And a commit "#1" with message "first commit" is created at "2015-05-27 14:01:17 UTC"
  And a commit "#2" with message "second commit" is created at "2015-05-27 15:04:19 UTC"
  And a developer prepares a review for UAT "http://uat.fundingcircle.com" with apps
    | app_name | version |
    | frontend | #2      |
  And adds the link to a comment for ticket "JIRA-123"

  When I view the releases for "frontend"

  Then I should see the releases
    | id | date                    | message       | issue audit |
    | #2 | 2015-05-27 15:04:19 UTC | second commit | view        |
    | #1 | 2015-05-27 14:01:17 UTC | first commit  |             |
