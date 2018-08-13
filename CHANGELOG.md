# CHANGELOG

## Upcoming

1. Remove rubocop_plus from Gemfile.  (Issue #23)
1. Update ruby versions in .travis.yml.  (Issue #24)
1. Use bundler 1.16.3 in .travis.yml.  (Issue #26)
1. Use `cri` `~> 2.12.0`.  (Issue #29)
1. Remove support for Ruby 2.2.  (Issue #31)

## 1.1.1 (May 06, 2018)

1. Cleanup rubocop issues in the `start_rspec` template that is installed in user applications.  (Issue #6)

## 1.1.0 (Feb 02, 2018)

1. Ensure the XVFB is detected correctly.  (Issue #5)
1. Prepare the database when the project is a Rails engine.  (Issue #7)
1. Add an `rspec_starter --init` command that installs an initial script.  (Issue #9)
1. Add rubocop_plus gem for internal code cleanup.  (Issue #11)
1. Change the highlight color of the output from yellow to blue.  (Issue #15)

## 1.0.1 (May 10, 2017)

1. Improve the logic for deciding when the database preparation step has successfully completed, and format the error output better.  (Issue #1)

## 1.0.0 (Apr 06, 2017)

1. Initial Release
