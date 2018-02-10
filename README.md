# rspec_starter

rspec_starter is a Ruby gem that simplifies the process of running RSpec.  Large development teams often manage multiple projects.  When developers move around projects, it can be unclear how to start RSpec in a way that runs the test suite properly for a given project.  Hopefully someone took the time to explain how to do it in the README, but this frequently doesn't happen.

With rspec_starter, a script is created which specifies how to run RSpec properly for the application.  Anyone can invoke the script to run the rspec test suite.  No confusion.  Self documenting.  Amazing.

rspec_starter also helps smooth out differences between operating systems.  For example, MacOS provides it's own display server for running feature tests whereas Linux operating systems may need to start a display sever, like XVFB, before feature tests will pass.  Once rspec_starter is setup, developers simply execute the script and rspec_starter does the rest.

At the moment, rspec_starter works for Rails applications and raw ruby applications/gems that are not database dependent.  We can support other frameworks if needed desired.

### Main Steps

RSpec runner can curently perform the following steps (these steps can be toggled on or off)

- Prepare a Rails database by running `rake db:drop db:create db:migrate RAILS_ENV=test`
- Remove the `tmp` folder if it exists
- Verify XVFB is installed when running on a Linux box
- Start RSpec with 'bundle exec rspec' or 'xvfb-run bundle exec rspec' as needed

## Versioning Strategy

This gem uses [semver](semver.org).

## Installation

### Rails

Add this line to your application's Gemfile:

```ruby
gem 'rspec_starter', require: false
```

And then execute:

    $ bundle

Inside the `bin` folder, create file called `start_rspec` (it can be named anything you like).

Run `chmod +x start_rspec` to make the file executable.

Add the following contents to the file

    #!/usr/bin/env ruby

    # Execute this script to run RSpec for the app.
    # To run all specs, navigate to the application's root folder and execute
    #   bin/start_rspec
    # rspec_starter takes command line options and forwards unknown options to rspec
    #   bin/start_rspec --no-prep-db spec/features
    # See the help output for more advanced ways to run the script
    #   bin/start_rspec --help

    require "bundler/setup"
    require "rspec_starter"

    # The path to the application's root folder.
    APP_ROOT = Pathname.new File.expand_path('../../', __FILE__)

    # Run commands in the context of the application's root folder.
    Dir.chdir APP_ROOT do
      # Arguments passed to 'start' define the steps needed to cleanly run RSpec.
      # Command line options may change execution on a per-run basis.
      RspecStarter.start(prepare_db: true, remove_tmp: true, allow_xvfb: true)
    end

## Usage

`cd` into the root of your application/project and invoke the script.  For these examples, it is assumed you placed the script in the `bin` folder of your app.

    $ bin/start_rspec

The above command will run the entire test suite.  You can pass options to the script as well.  Some of the options will be consumed by start_rspec and some will be forwarded on to rspec.  As a result, you could do something like

    $ bin/start_rspec spec/features

which tells start_rspec, to tell rspec, to only run the feature tests.  Run the following command to see other ways to use the script

    $ bin/start_rspec --help

## Configuration

The entire idea behind start_rspec is to standardize the process of starting application.  You can modify the `bin/start_rspec` file (assuming you put `start_rspec` inside the `bin` folder of your project) to do whatever you want.  If you open that file, you'll see that it basically does one thing - it calls the following command in the context of the root folder, of your project:

    RspecStarter.start(prepare_db: true, remove_tmp: true, allow_xvfb: true)

The arguments passed to `start_rspec`, represent the defaults you consider important for achieving a clean RSpec run.  If your particular project doesn't have a DB, or you don't need it prepared before each Rspec run, you could turn that step off by passing `prepare_db: false`.

Be careful about the steps you enable/disable inside the script file.  **The goal is to define steps that help people, with limited knowledge of the app, successfully run the test suite.**  Having said that, it's certainly a waste of time to prepare the test database if you just ran the test suite and you know it's empty (start_rspec doesn't advocate seeding the test database).  If you want to turn steps off on a per run basis, you can use command line options.  Run `bin/start_rspec --help` to see a list of available options.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/roberts1000/rspec_starter.

