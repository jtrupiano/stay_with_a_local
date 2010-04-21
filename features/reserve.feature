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
    
    When "Dave Troy" approves the reservation request
    Then I should see "You have accepted a room request"
    And "jamesgolick" should receive a confirmation email
    
    And "Dave Troy" should have 2 available rooms
    And "jamesgolick" should be staying with "Dave Troy"
    
  Scenario: A host rejects a reservation request
    Given a host "Paul Barry" with 1 available room
    And "jamesgolick" has submitted a room request to "Paul Barry"
    When "Paul Barry" declines the reservation request
    Then "jamesgolick" should receive a declination email
    And "Paul Barry" should have 1 available room
