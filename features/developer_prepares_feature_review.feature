Feature: Developer prepares a feature review so that it can be attached to a
  ticket for a PO to use in acceptance.

Scenario: Preparing link for ticket
  Given an application called "frontend"
  And an application called "backend"
  And an application called "irrelevant"
  And I prepare a feature review for:
    | app_name | version |
    | frontend | abc     |
    | backend  | def     |
  Then I should see the feature review page with:
    | app_name | version |
    | frontend | abc     |
    | backend  | def     |
