Feature: list all trouted files

  Scenario: list files
    Given a directory named "upstream_repo"
    And a directory named "child_repo"
    And a file named "upstream_repo/Gemfile" with:
      """
      source "http://rubygems.org"
      gem "rails"
      gem "mysql"
      """
    When I cd to "upstream_repo"
    And I run "git init"
    And I run "git add Gemfile"
    And I run "git commit -m 'Added gemfile'"
    And I cd to "../child_repo"
    And I run "trout checkout Gemfile ../upstream_repo"
    And I run "trout list"
    Then the output should contain:
      """
      Gemfile
      """
    When I cd to "../upstream_repo"
    And I write to ".gitignore" with:
      """
      tmp/
      """
    And I run "git add .gitignore"
    And I run "git commit -m 'Added gitignore'"
    And I cd to "../child_repo"
    And I run "trout checkout .gitignore ../upstream_repo"
    And I run "trout list"
    Then the output should contain:
      """
      Gemfile
      """
    And the output should contain:
      """
      .gitignore
      """
