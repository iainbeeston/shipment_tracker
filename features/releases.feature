Feature: Viewing Releases
  As a deployer and an auditor I want to view all releases for a given application

Scenario: Viewing releases for an app
  Given an application called "frontend"
  And a ticket "JIRA-123" with summary "Urgent ticket" and description "Urgent stuff" is started
  And a commit "#master1" with message "historic commit" is created at "2015-05-27 13:01:17 UTC"
  And the branch "feature-one" is checked out
  And a commit "#branch1" with message "first commit" is created at "2015-05-27 14:01:17 UTC"
  And a commit "#branch2" with message "second commit" is created at "2015-05-27 15:04:19 UTC"
  And a developer prepares a review for UAT "http://uat.fundingcircle.com" with apps
    | app_name | version  |
    | frontend | #branch2 |
  And adds the link to a comment for ticket "JIRA-123"
  And ticket "JIRA-123" is approved by "alice@fundingcircle.com" at "2015-06-07T15:24:34.957+0100"
  And the branch "master" is checked out
  And a commit "#master2" with message "recent commit" is created at "2015-05-27 13:31:17 UTC"
  And the branch "feature-one" is merged at "2015-05-27 16:04:19 UTC"

  When I view the releases for "frontend"

  Then I should see the releases
    | id       | date                    | message                            | issue audit |
    |          | 2015-05-27 16:04:19 UTC | Merged `feature-one` into `master` |             |
    | #branch2 | 2015-05-27 15:04:19 UTC | second commit                      | Done        |
    | #branch1 | 2015-05-27 14:01:17 UTC | first commit                       | Done        |
    | #master2 | 2015-05-27 13:31:17 UTC | recent commit                      |             |
    | #master1 | 2015-05-27 13:01:17 UTC | historic commit                    |             |
