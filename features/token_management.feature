@logged_in
Feature: Token management

Scenario: Generating a token
  When I generate a token for "JIRA" with name "app1"
  Then I should see the tokens
    | Source   | Name | Endpoint |
    | JIRA     | app1 | jira     |

Scenario: Revoking a token
  When I generate a token for "JIRA" with name "app1"
  And I revoke it
  Then I should not see any tokens
