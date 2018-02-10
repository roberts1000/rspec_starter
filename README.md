# rspec_starter

rspec_starter is a Ruby gem that simplifies the process of running RSpec.  Large development teams often manage multiple projects.  Those projects tend to have subtle differences in how rspec should be invoked.  Hopefully someone took the time to explain how to do it in the README, but this frequently doesn't happen.

With rspec_starter, a script is created which specifies how to run RSpec properly for the application.  Anyone can invoke the `bin/start_rspec` script to run the rspec test suite.  No confusion.  Self documenting.  Amazing.

rspec_starter also helps smooth out differences between operating systems.  For example, MacOS provides it's own display server for running feature tests whereas Linux operating systems may need to start a display sever, like XVFB, before feature tests will pass.  Once rspec_starter is setup, developers simply execute the script and rspec_starter does the rest.

At the moment, rspec_starter works for Rails applications, Rails Engines and raw ruby applications/gems that are not database dependent.

### Main Steps

rspec_starter can curently perform the following steps (these steps can be toggled on or off)

- Prepare a Rails database (or dummy database inside a Rails engine) by running `rake db:drop db:create db:migrate RAILS_ENV=test`
- Remove the `tmp` folder if it exists
- Verify XVFB is installed when running on a Linux box
- Start RSpec with `bundle exec rspec` or `xvfb-run bundle exec rspec` (depending on the needs of the OS)

## Versioning Strategy

This gem uses [Semver](semver.org) 2.0.0.

## Installation

### Rails Applications & Rails Engines

Add this line to your Gemfile of your Rails application or Rails Engine:

```ruby
group :development do
  gem 'rspec_starter', require: false
end
```

And then execute:

    $ bundle

Run the installer

    $ rspec_starter --init

The above command installs the script you will use to run rspec.  Make sure it is exectuable

    $ chmod +x bin/start_rspec

The file is named `start_rspec`, but you can rename it to anything you like.

## Usage

`cd` into the root of your application/project and invoke the script.  For these examples, it is assumed you placed the script in the `bin` folder of your app (but you could put it anywhere you like).

    $ bin/start_rspec

The above command will run the entire test suite.  You can pass options to the script as well.  Some of the options will be consumed by start_rspec and some will be forwarded on to rspec.  As a result, you could do something like

    $ bin/start_rspec spec/features

which tells start_rspec, to tell rspec, to only run the feature tests.  Run the following command to see other ways to use the script

    $ bin/start_rspec --help

## Configuration

The entire idea behind start_rspec is to standardize the process of starting application.  You can modify the `bin/start_rspec` file to do whatever you want.  If you open that file, you'll see that it does one thing - it calls the following command in the context of the root folder, of your project:

    RspecStarter.start(prepare_db: true, remove_tmp: true, allow_xvfb: true)

The arguments passed to `start_rspec`, represent the defaults you consider important for achieving a clean RSpec run.  If your particular project doesn't have a DB, or you don't need it prepared before each Rspec run, you could turn that step off by passing `prepare_db: false`.

Be careful about the steps you enable/disable inside the script file.  **The goal is to define steps that help people, with limited knowledge of the project, successfully run RSpec.**  It's best to have the bin/start_rspec define the best way to run rspec for newbies.  You can disable specific steps by passing in command line options.  Run `bin/start_rspec --help` to see a list of available options.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/roberts1000/rspec_starter.

