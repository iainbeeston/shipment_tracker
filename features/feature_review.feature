Feature: Developer prepares a feature review so that it can be attached to a
  ticket for a PO to use in acceptance.

Background:
  Given an application called "frontend"
  And an application called "backend"
  And an application called "irrelevant"

Scenario: Preparing link for ticket
  When I prepare a feature review for:
    | field name | content             |
    | frontend   | abc123456789        |
    | backend    | def123456789        |
    | uat_url    | http://www.some.url |
  Then I should see the feature review page with the applications:
    | app_name | version |
    | frontend | abc1234 |
    | backend  | def1234 |
  And I can see the UAT environment "http://www.some.url"

Scenario: Viewing a feature review
  Given a ticket "JIRA-123" with summary "Urgent ticket" and description "Urgent stuff" is started
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
  And a developer prepares a review for UAT "http://uat.fundingcircle.com" with apps
    | app_name | version |
    | frontend | #abc    |
    | backend  | #def    |
  And adds the link to a comment for ticket "JIRA-123"

  When I visit the feature review

  Then I should see a summary with heading "danger" and content
    | status | title           |
    | failed | Tests           |
    | failed | UAT environment |
    | n/a    | QA (manual)     |

  And I should only see the ticket
    | key      | summary       | description  | status      |
    | JIRA-123 | Urgent ticket | Urgent stuff | In Progress |

  And I should see the builds with heading "danger" and content
    | status  | app      | source   |
    | success | frontend | CircleCi |
    | failed  | backend  | CircleCi |
    | success | backend  | CircleCi |

  And I should see the deploys to UAT with heading "danger" and content
    | app_name   | version | correct |
    | frontend   | #abc    | yes     |
    | backend    | #old    | no      |
    | irrelevant | #ghi    |         |

Scenario: QA rejects and approves feature
  Given a developer prepares a review for UAT "http://uat.fundingcircle.com" with apps
    | app_name | version |
    | frontend | abc     |
    | backend  | def     |
  When I visit the feature review
  And I "reject" the feature as "Alice"
  Then I should see the feature "rejected" by "Alice"
  When I "accept" the feature as "Alice"
  Then I should see the feature "accepted" by "Alice"

