Feature: View deploys

  Scenario: A developer deploys an app
    Given Alice has deployed an app
    When I visit /deploys
    Then I should see a deploy by Alice
