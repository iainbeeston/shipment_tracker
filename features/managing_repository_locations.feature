@logged_in
Feature: Managing Repository Locations

Scenario: As a PO I want the ability to add repository locations
  Given I am on the new repository location form
  When I enter "new_app" and "ssh://example.com/new_app"
  Then I should see the repository locations:
    | Name    | URI                       |
    | new_app | ssh://example.com/new_app |
