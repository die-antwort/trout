@cur
Feature: Update all files at once

  Background:
    Given I have an upstream repo with two files
    And I have an child repo also containing those two files 
  
  Scenario:  
    Given I update both files in the upstream repo
    When I run "trout update-all" in the child repo
    Then the updates should be merged into both files in the child repo