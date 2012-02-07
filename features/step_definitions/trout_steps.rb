# Using api methods from aruba gem for file operations

Given /^I have an upstream repo with two files$/ do
  create_dir "upstream_repo"
  cd "upstream_repo"
  create_file "file", "Dolor lorem ipsum"
  create_file "other_file", "Foo\nBar\n"
  run "git init ."
  run "git add ."
  run "git commit -m 'Initial commit'"
  cd ".."
end

Given /^I have an child repo also containing those two files$/ do
  create_dir "child_repo"
  cd "child_repo"
  run "trout checkout file ../upstream_repo"
  run "trout checkout other_file ../upstream_repo"
  cd ".."
end

Given /^I update both files in the upstream repo$/ do
  cd "upstream_repo"
  append_to_file "file", " sit amet, consectetur."
  append_to_file "other_file", "Baz\n"
  run "git commit -am 'Update both files'"
  cd ".."
end

When /^I run "([^"]*)" in the child repo$/ do |cmd|
  cd "child_repo"
  run cmd
  cd ".."
end

Then /^the updates should be merged into both files in the child repo$/ do
  cd "child_repo"
  check_file_content "file", "Dolor lorem ipsum sit amet, consectetur.", true
  check_file_content "other_file", "Foo\nBar\nBaz\n", true
  cd ".."
end
