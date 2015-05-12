Feature: Feature audit comments
  As a product owner sometimes I need to explain why a report looks the way it
  does. I want to be able to comment on the report so that this reasoning is
  recorded.

Scenario: Commenting on a feature audit
  Given an application with some commits
  And I am on the feature audit page for the last commit
  When I submit a comment with message "unauthorised commit done for refactoring" and name "Bob"
  Then I should see the comments
    | name | message                                  |
    | Bob  | unauthorised commit done for refactoring |
