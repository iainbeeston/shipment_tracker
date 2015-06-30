@fake_authentication
Feature: Developer prepares a feature review so that it can be attached to a
  ticket for a PO to use in acceptance.

Background:
  Given I am logged in as "marcus@shipment-tracker.url"
  Given an application called "frontend"
  And an application called "backend"
  And an application called "mobile"
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
  Given a ticket "JIRA-123" with summary "Urgent ticket" is started
  And a commit "#abc" by "Alice" is created for app "frontend"
  And a commit "#old" by "Bob" is created for app "backend"
  And a commit "#def" by "Bob" is created for app "backend"
  And a commit "#ghi" by "Carol" is created for app "mobile"
  And a commit "#xyz" by "Wendy" is created for app "irrelevant"
  And CircleCi "passes" for commit "#abc"
  And CircleCi "fails" for commit "#def"
  # Flaky tests, build retriggered.
  And CircleCi "passes" for commit "#def"
  And commit "#abc" is deployed by "Alice" on server "http://uat.fundingcircle.com"
  And commit "#old" is deployed by "Bob" on server "http://uat.fundingcircle.com"
  And commit "#def" is deployed by "Bob" on server "http://other-uat.fundingcircle.com"
  And commit "#xyz" is deployed by "Wendy" on server "http://uat.fundingcircle.com"
  And a developer prepares a review for UAT "http://uat.fundingcircle.com" with apps
    | app_name | version |
    | frontend | #abc    |
    | backend  | #def    |
    | mobile   | #ghi    |
  And adds the link to a comment for ticket "JIRA-123"

  When I visit the feature review

  Then I should see a summary with heading "danger" and content
    | status  | title           |
    | n/a     | Test Results    |
    | failed  | UAT Environment |
    | n/a     | QA Acceptance   |

  And I should only see the ticket
    | Key      | Summary       | Status      |
    | JIRA-123 | Urgent ticket | In Progress |

  And I should see the builds with heading "warning" and content
    | status  | app      | source   |
    | success | frontend | CircleCi |
    | success | backend  | CircleCi |
    | n/a     | mobile   |          |

  And I should see the deploys to UAT with heading "danger" and content
    | app_name   | version | correct |
    | frontend   | #abc    | yes     |
    | backend    | #old    | no      |

Scenario: QA rejects and approves feature
  Given a developer prepares a review for UAT "http://uat.fundingcircle.com" with apps
    | app_name | version |
    | frontend | abc     |
    | backend  | def     |
  When I visit the feature review
  Then I should see the QA acceptance with heading "warning"

  When tester "Alice" "rejects" the feature
  Then I should see the QA acceptance with heading "danger" and name "Alice"

  When tester "Bob" "accepts" the feature
  Then I should see the QA acceptance with heading "success" and name "Bob"

Scenario: Feature review locks after the tickets get approved
  Given a ticket "JIRA-123" with summary "A ticket" is started
  Given a ticket "JIRA-124" with summary "A ticket" is started
  And a commit "#abc" by "Alice" is created for app "frontend"
  And CircleCi "passes" for commit "#abc"
  And commit "#abc" is deployed by "Alice" on server "http://uat.fundingcircle.com"
  And a developer prepares a review for UAT "http://uat.fundingcircle.com" with apps
    | app_name | version |
    | frontend | #abc    |
  And adds the link to a comment for ticket "JIRA-123"
  And adds the link to a comment for ticket "JIRA-124"

  When I visit the feature review
  And tester "Bob" "accepts" the feature

  Then I should see a summary with heading "success" and content
    | status  | title           |
    | success | Test Results    |
    | success | UAT Environment |
    | success | QA Acceptance   |

  When ticket "JIRA-123" is approved by "carol@fundingcircle.com" at "11:42:24"

  And CircleCi "fails" for commit "#abc"

  And I visit the feature review

  Then I should see a summary with heading "danger" and content
    | status  | title           |
    | failed  | Test Results    |
    | success | UAT Environment |
    | success | QA Acceptance   |

  And CircleCi "passes" for commit "#abc"

  When ticket "JIRA-124" is approved by "carol@fundingcircle.com" at "11:45:24"

  And CircleCi "fails" for commit "#abc"
  And a commit "#xyz" by "David" is created for app "frontend"
  And commit "#xyz" is deployed by "David" on server "http://uat.fundingcircle.com"
  And tester "Bob" "rejects" the feature

  And I visit the feature review

  Then I should see that the feature review is locked

  And a summary with heading "success" and content
    | status  | title           |
    | success | Test Results    |
    | success | UAT Environment |
    | success | QA Acceptance   |

  When ticket "JIRA-123" is rejected

  And I visit the feature review

  Then I should see that the feature review is not locked

  And a summary with heading "danger" and content
    | status  | title           |
    | failed  | Test Results    |
    | failed  | UAT Environment |
    | failed  | QA Acceptance   |
