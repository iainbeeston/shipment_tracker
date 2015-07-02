@logged_in
Feature: Auditor searches a Feature Review.

Background:
  Given an application called "frontend"
  And a ticket "JIRA-123" with summary "Urgent ticket" is started
  And a commit "#master1" with message "initial commit" is created at "13:01:17"
  And the branch "feature-one" is checked out
  And a commit "#commit1" with message "first commit" is created at "14:01:17"
  And a developer prepares a review for UAT "http://uat.fundingcircle.com" with apps
    | app_name | version  |
    | frontend | #commit1 |
  And adds the link to a comment for ticket "JIRA-123"
  And a commit "#commit2" with message "second commit" is created at "15:04:19"
  And a developer prepares a review for UAT "http://uat.fundingcircle.com" with apps
    | app_name | version  |
    | frontend | #commit2 |
  And adds the link to a comment for ticket "JIRA-123"
  And ticket "JIRA-123" is approved by "alice@fundingcircle.com" at "15:24:34"
  And the branch "master" is checked out
  And a commit "#commit3" with message "recent commit" is created at "13:31:17"
  And the branch "feature-one" is merged with merge commit "#merge" at "16:04:19"

Scenario: Searching for a Feature Review
  When I look up feature reviews for "#commit1" on "frontend"
  Then I should see the feature review for
    | app_name | version  | uat                          |
    | frontend | #commit1 | http://uat.fundingcircle.com |
    | frontend | #commit2 | http://uat.fundingcircle.com |
  And I select link to feature review "2"
  Then I should see the feature review page with the applications:
    | app_name | version  |
    | frontend | #commit2 |

Scenario: Searching for a commit with no associated Feature Reviews
  When I look up feature reviews for "#master1" on "frontend"
  Then I should see a warning: "No Feature Reviews found."
