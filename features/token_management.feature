@logged_in
Feature: Token management

Scenario: Generating a token
  When I generate a token for "circleci"
  Then I should see a token for "circleci" with a value

Scenario: Revoking a token
  When I generate a token for "circleci"
  And I revoke it
  Then I should not see any tokens
