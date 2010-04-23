Feature: Reserve a room
  In order to welcome the RailsConf speakers
  RailsConf speakers
  should be able to reserve a room with a local
  
  Scenario: A RailsConf speaker reserves a room
    Given a host "Dave Troy" with 3 available rooms
    When I am not authenticated
    And I view the rooms available
    Then I should not be able to reserve a room
    
    When I authenticate with twitter as "jamesgolick"
    And I view the rooms available
    Then I should be able to reserve a room
    
    When I choose to "Stay with Dave"
    Then I should see "Request a Room with Dave"
    
    When I fill in the following:
      | Email     | arailsconfspeaker@localhost |
      | Comments  | I'm only staying through Wednesday |
    And I press "Stay with Dave"
    Then I should see "You have submitted a room request to Dave Troy"
    And "Dave Troy" should receive a request email
    
    When "Dave Troy" accepts the room request
    Then I should see "You have accepted a room request"
    And "jamesgolick" should receive a confirmation email
    
    And "Dave Troy" should have 2 available rooms
    And "jamesgolick" should be staying with "Dave Troy"
    
  Scenario: A host declines a room request
    Given a host "Paul Barry" with 1 available room
    And "jamesgolick" has submitted a room request to "Paul Barry"
    When "Paul Barry" declines the room request
    Then "jamesgolick" should receive a declination email
    And "Paul Barry" should have 1 available room

  Scenario: A host with several available rooms accepts a few requests
    Given a host "Paul Barry" with 2 available rooms
    And "jamesgolick" has submitted a room request to "Paul Barry"
    And "wycats" has submitted a room request to "Paul Barry"
    And "joedamato" has submitted a room request to "Paul Barry"
    And "flipsasser" has submitted a room request to "Paul Barry"
    When "Paul Barry" accepts the room request from "wycats"
    Then "wycats" should receive a confirmation email
    
    When "Paul Barry" accepts the room request from "joedamato"
    Then "jamesgolick" should receive a declination email
    And "flipsasser" should receive a declination email
    
    When "Paul Barry" accepts the room request from "flipsasser"
    Then I should see "You have already processed the room request from flipsasser"
    
    When "Paul Barry" declines the room request from "wycats"
    Then I should see "You have already processed the room request from wycats"
    
    When "Paul Barry" declines the room request from "jamesgolick"
    Then I should see "You have already processed the room request from jamesgolick"
    
  # Scenario: A guest cannot submit two room requests
  #   Given a host "Paul Barry" with 1 available room
  #   And "jamesgolick" has submitted a room request to 
  #   
  # Scenario: A host accepts a room request for someone that is already accepted