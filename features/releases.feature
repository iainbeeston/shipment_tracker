@logged_in
Feature: Viewing Releases
  As a deployer I want to view all releases for a given application so that I know which versions are safe
  to deploy

Scenario: Viewing releases for an app
  Given an application called "frontend"
  And a ticket "JIRA-123" with summary "Urgent ticket" is started
  And a commit "#master1" with message "historic commit" is created at "13:01:17"
  And the branch "feature-one" is checked out
  And a commit "#branch1" with message "first commit" is created at "14:01:17"
  And a commit "#branch2" with message "second commit" is created at "15:04:19"
  And a developer prepares a review for UAT "http://uat.fundingcircle.com" with apps
    | app_name | version  |
    | frontend | #branch2 |
  And adds the link to a comment for ticket "JIRA-123"
  And ticket "JIRA-123" is approved by "alice@fundingcircle.com" at "15:24:34"
  And the branch "master" is checked out
  And a commit "#master2" with message "recent commit" is created at "13:31:17"
  And the branch "feature-one" is merged with merge commit "#merge" at "16:04:19"

  When I view the releases for "frontend"

  Then I should see the releases
    | version  | date     | subject                            | issue audit          | approved |
    | #merge   | 16:04:19 | Merged `feature-one` into `master` | Ready for Deployment | yes      |
    | #branch2 | 15:04:19 | second commit                      | Ready for Deployment | yes      |
    | #branch1 | 14:01:17 | first commit                       | Ready for Deployment | yes      |
    | #master2 | 13:31:17 | recent commit                      |                      | no       |
    | #master1 | 13:01:17 | historic commit                    |                      | no       |
