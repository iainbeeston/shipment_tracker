Feature: View deploys

  Scenario: A developer deploys an app
    Given a deploy
      | app_name        | deployer  | time             | software version | server                  |
      | hello_world_app | Alice     | 2014-03-20 19:03 | abc123           | hello_world.fcuat.co.uk | 
    When I visit "/release_audits/hello_world_app"
    Then I should see a deploy
    	| deployer  | time             | software version | server                  |
    	| Alice     | 2014-03-20 19:03 | abc123           | hello_world.fcuat.co.uk |
