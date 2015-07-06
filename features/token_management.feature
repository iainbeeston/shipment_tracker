@logged_in
Feature: Token management

Scenario: Generating a token
  When I generate a token for "CircleCI" with name "app1"
  Then I should see the tokens
    | Source   | Name | Endpoint |
    | CircleCI | app1 | circleci |

Scenario: Revoking a token
  When I generate a token for "CircleCI" with name "app1"
  And I revoke it
  Then I should not see any tokens
