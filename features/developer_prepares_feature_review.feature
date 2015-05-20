Feature: Developer prepares a feature review so that it can be attached to a
  ticket for a PO to use in acceptance.

Scenario: Preparing link for ticket
  Given an application called "frontend"
  And an application called "backend"
  And an application called "irrelevant"
  And I prepare a feature review for:
    | field name | content             |
    | frontend   | abc                 |
    | backend    | def                 |
    | uat_url    | http://www.some.url |
  Then I should see the feature review page with the applications:
    | app_name | version |
    | frontend | abc     |
    | backend  | def     |
  And I can see the UAT environment "http://www.some.url"

Scenario: View builds for feature review
  Given an application called "frontend"
  And an application called "backend"
  And an application called "irrelevant"
  And CircleCi "passes" for commit "abc"
  And CircleCi "fails" for commit "def"
  # Flaky tests, build retriggered.
  And CircleCi "passes" for commit "def"

  When I visit a feature review for:
    | app_name | version |
    | frontend | abc     |
    | backend  | def     |

  Then I should see the builds for "frontend"
    | source   | status  | commit |
    | CircleCi | success | abc    |

  Then I should see the builds for "backend"
    | source   | status  | commit |
    | CircleCi | failed  | def    |
    | CircleCi | success | def    |
