# CHANGELOG

Issues marked as **(Internal)** mark internal development work. Issues are tracked at https://github.com/roberts1000/rspec_starter/issues.

## Next Release

1. [#90](../../issues/90) Use `pry-byebug ~> 3.9.0`. **(Internal)**

## 1.7.2 (Dec 20, 2019)

1. [#84](../../issues/84) Removed unneeded `/` in templates.

## 1.7.1 (Dec 13, 2019)

1. [#80](../../issues/80) Fix call to missing `remove_dummy` method.

## 1.7.0 (Dec 12, 2019)

1. [#74](../../issues/74) Make `rspec_starter --init` detect Rails engines correctly.
1. [#75](../../issues/75) Let `remove_tmp_folder` task remove the tmp folder from `dummy` apps.

## 1.6.0 (Dec 09, 2019)

1. [#56](../../issues/56) Move old starter code to a `legacy` folder so it can still be used. **(Internal)**
1. [#58](../../issues/58) Add step based interface.
1. [#59](../../issues/59) Use `rake ~> 13.0` for development. **(Internal)**
1. [#61](../../issues/61) Use `pry-byebug ~> 3.7.0` for development. **(Internal)**
1. [#63](../../issues/63) Modernize the CHANGELOG. **(Internal)**
1. [#66](../../issues/66) Update ruby versions and use bundler 2.0.2 in `travis.yml`. **(Internal)**

## 1.5.0 (Feb 19, 2019)

1. [#51](../../issues/51) Report an exit status of 1 if DB Preparation or RSpec fails.

## 1.4.0 (Oct 12, 2018)

1. [#41](../../issues/41) Isolate rebuild command string into a dedicated method. **(Internal)**
1. [#43](../../issues/43) Add instructions for creating custom steps.
1. [#45](../../issues/45) Fix the database rebuild command hanging when there's too much output.

## 1.3.0 (Aug 30, 2018)

1. [#37](../../issues/37) Change `cri` version to `~> 2.0`.

## 1.2.0 (Aug 08, 2018)

1. [#23](../../issues/23) Remove `rubocop_plus` from Gemfile. **(Internal)**
1. [#24](../../issues/24) Update ruby versions in `.travis.yml`. **(Internal)**
1. [#26](../../issues/26) Use `bundler` `1.16.3` in `.travis.yml`. **(Internal)**
1. [#29](../../issues/29) Use `cri` `~> 2.12.0`.
1. [#31](../../issues/31) Remove support for Ruby 2.2.
1. [#33](../../issues/33) Use `rake` `~> 12.0` in development. **(Internal)**

## 1.1.1 (May 06, 2018)

1. [#6](../../issues/6) Cleanup rubocop issues in the `start_rspec` template.

## 1.1.0 (Feb 02, 2018)

1. [#5](../../issues/5) Ensure XVFB is detected correctly.
1. [#7](../../issues/7) Prepare the database when the project is a Rails engine.
1. [#9](../../issues/9) Add an `rspec_starter --init` command that installs an initial script.
1. [#11](../../issues/11) Add `rubocop_plus` gem for internal code cleanup. **(Internal)**
1. [#15](../../issues/15) Change the highlight color of the output from yellow to blue.

## 1.0.1 (May 10, 2017)

1. [#1](../../issues/1) Improve the logic for deciding when the database preparation step successfully completes.

## 1.0.0 (Apr 06, 2017)

1. Initial Release
