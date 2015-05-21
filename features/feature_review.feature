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

Scenario: Viewing a feature review
  Given an application called "frontend"
  And an application called "backend"
  And an application called "irrelevant"
  And a commit "#abc" by "Alice" is created for app "frontend"
  And a commit "#old" by "Bob" is created for app "backend"
  And a commit "#def" by "Bob" is created for app "backend"
  And a commit "#ghi" by "Carol" is created for app "irrelevant"
  And CircleCi "passes" for commit "#abc"
  And CircleCi "fails" for commit "#def"
  # Flaky tests, build retriggered.
  And CircleCi "passes" for commit "#def"
  And commit "#abc" is deployed by "Alice" on server "http://uat.fundingcircle.com"
  And commit "#old" is deployed by "Bob" on server "http://uat.fundingcircle.com"
  And commit "#def" is deployed by "Bob" on server "http://other-uat.fundingcircle.com"
  And commit "#ghi" is deployed by "Carol" on server "http://uat.fundingcircle.com"

  When I visit a feature review for UAT "http://uat.fundingcircle.com" and apps:
    | app_name | version |
    | frontend | #abc    |
    | backend  | #def    |

  Then I should see the builds for "frontend"
    | source   | status  | commit |
    | CircleCi | success | #abc   |

  And I should see the builds for "backend"
    | source   | status  | commit |
    | CircleCi | failed  | #def   |
    | CircleCi | success | #def   |

  And I should see the deploys
    | app_name   | version | correct |
    | frontend   | #abc    | yes     |
    | backend    | #old    | no      |
    | irrelevant | #ghi    |         |