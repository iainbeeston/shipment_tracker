@logged_in
Feature: Token management

Scenario: Generating a token
  When I generate a token for "circleci" with name "app1"
  Then I should see a token for "circleci" with name "app1"

Scenario: Revoking a token
  When I generate a token for "circleci" with name "app1"
  And I revoke it
  Then I should not see any tokens
