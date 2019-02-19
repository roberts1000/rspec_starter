# rspec_starter

rspec_starter is a Ruby gem that simplifies the process of running RSpec.  Large development teams often manage multiple projects.  Those projects tend to have subtle differences in how rspec should be invoked.  Hopefully someone took the time to explain how to do it in the README, but this frequently doesn't happen.

With rspec_starter, a script is created which specifies how to run RSpec properly for the application.  Anyone can invoke the `bin/start_rspec` script to run the rspec test suite.  No confusion.  Self documenting.  Amazing.

rspec_starter also helps smooth out differences between operating systems.  For example, MacOS provides it's own display server for running feature tests whereas Linux operating systems may need to start a display sever, like XVFB, before feature tests will pass.  Once rspec_starter is setup, developers simply execute the script and rspec_starter does the rest.

At the moment, rspec_starter works for Rails applications, Rails Engines and raw ruby applications/gems that are not database dependent.

### Main Steps

rspec_starter can currently perform the following steps (these steps can be toggled on or off)

- Prepare a Rails database (or dummy database inside a Rails engine) by running `rake db:drop db:create db:migrate RAILS_ENV=test`
- Remove the `tmp` folder if it exists
- Verify XVFB is installed when running on a Linux box
- Start RSpec with `bundle exec rspec` or `xvfb-run bundle exec rspec` (depending on the needs of the OS)

## Version Policy

Releases are versioned using [semver 2.0.0](https://semver.org/spec/v2.0.0.html).

## Supported Ruby Versions

2.3.0+

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

The above command installs the script you will use to run rspec.  The file is named `start_rspec`, but you can rename it to anything you like.

## Usage

`cd` into the root of your application/project and invoke the script.  For these examples, it is assumed you placed the script in the `bin` folder of your app (but you could put it anywhere you like).

    $ bin/start_rspec

The above command will run the entire test suite.  You can pass options to the script as well.  Some of the options will be consumed by start_rspec and some will be forwarded on to rspec.  As a result, you could do something like

    $ bin/start_rspec spec/features

which tells start_rspec, to tell rspec, to only run the feature tests.  Run the following command to see other ways to use the script

    $ bin/start_rspec --help

## Custom Steps

rspec_starter does not currently have support for creating custom steps.  However, there are some techniques that can achieve the same results.  rspec_starter currently implements 4 "steps" which can be turned on or off.  The steps are implemented by classes and are evaluated in this order:

1. `VerifyXvfbStep` - Ensures xvfb is installed on systems where it should be used (.i.e. Linux).
1. `PrepareDatabaseStep` - Runs `rake db:drop db:create db:migrate RAILS_ENV=test`.
1. `RemoveTmpFolderStep` - Deletes the `tmp` folder.
1. `InvokeRspecStep` - Runs `bundle exec rspec`.

All steps implement an `execute` method that actually runs the step. You can inject custom code before or after any one of those steps.

#### Using prepend to Inject a Custom Module

One strategy is to open the `bin/start_rspec` file use `prepend` to inject a custom module into the class.

```ruby
require "bundler/setup"
require "rspec_starter"

# The path to the application's root folder.
APP_ROOT = Pathname.new File.expand_path('../../', __FILE__)

module CustomStep
  def execute
    # Place code above the super call if you want it run before the targeted step
    super # super needs to be called if you want the targeted step to execute
    # Place code after the super call if you want it run after the targeted step
  end
end

RspecStarter::PrepareDatabaseStep.prepend CustomStep

Dir.chdir APP_ROOT do
  RspecStarter.start(prepare_db: true, remove_tmp: true, allow_xvfb: true)
end
```

In the above example, the `PrepareDatabaseStep` is targeted.  By prepending the `CustomStep` module to `PrepareDatabaseStep`, it ensures  the `execute` in `CustomStep` is executed before the `execute` method in the targeted step..  At that point, you can execute any code you want, then call `super` to run targeted step, then run any code after the targeted step completes.

**Note:** If you're trying to run additional rake tasks on the database using this technique, it probably won't work.  Your custom rake task will execute in a different process from the rake tasks that rspec_starter runs.  This will prevent some changes from getting saved to the database.  The techniques described below can help in this situation.

#### Customizing the Database Prep Step

Database preparation is performed by `PrepareDatabaseStep`.  You can use the above `prepend` technique to add code before/after this step runs, but you can also customize the exact command that is run to prepare your db.  By default, `PrepareDatabaseStep` runs `rake db:drop db:create db:migrate RAILS_ENV=test` on your application (as seen [here](https://github.com/roberts1000/rspec_starter/blob/v1.4.0/lib/rspec_starter/steps/prepare_database_step.rb#L46)).  You can override that command with:

```
module CustomStep
  def rebuild_command
    "rake db:drop db:create db:migreate db:do_something_else RAILS_ENV=test"
  end
end

RspecStarter::PrepareDatabaseStep.prepend CustomStep
```

In this case, calling `super` isn't needed because we don't care about the default implementation.

**Note:** When using this technique, any output written to the console by rake tasks will not be displayed because the `PrepareDatabaseStep` supresses the output.

#### Invoking Custom Rake Tasks

There are several ways to invoke rake tasks in Ruby.  Backticks don't seem to work in `rspec_starter`, but calling `system` does work

```ruby
module CustomStep
  def execute
    super
    system("bundle exec rake do_something_else_after_db_is_prepped")
  end
end

RspecStarter::PrepareDatabaseStep.prepend CustomStep
```

You can also invoke the task without calling out to the system.  This should also be faster since the Kernel won't have to setup the process.

```ruby
require 'rake'
require File.expand_path('config/environment', APP_ROOT)
ReplaceWithAppName::Application.load_tasks

module CustomTask
  def execute
    super
    Rake::Task["do_something_else_after_db_is_prepped"].invoke
  end
end

RspecStarter::PrepareDatabaseStep.prepend CustomTask
```

In this technique, you must replace the `ReplaceWithAppName` with the name of your Rails application.  Open the `config/application.rb` file to find the correct name.

#### Appending to Existing Rake Tasks

You can also bypass rspec_starter completely and add additional logic to existing rake tasks.  For example, if you **always** want to peform an extra task after `db:migrate` is executed, you can add the following to your `lib/db_migrate.rake` folder:

```ruby
namespace :db do
  task :migrate do
    # do something additional
  end
end
```

or

```ruby
namespace :db do
  task :migrate do
    Rake::Task["another_task_name"].invoke
  end
end
```

When you redefine an existing rake task, rake actually apends your custom code to the existing rake task instead of overwriting it.  If needed, you can also add additional guards to conditionally add the custom logic:


```ruby
if Rails.env == "development"
  namespace :db do
    task :migrate do
      Rake::Task["another_task_name"].invoke
    end
  end
end
```

## Configuration

The entire idea behind start_rspec is to standardize the process of starting RSpec for an application.  You can modify the `bin/start_rspec` file to do whatever you want.  If you open that file, you'll see that it does one thing - it calls the following command in the context of the root folder, of your project:

    RspecStarter.start(prepare_db: true, remove_tmp: true, allow_xvfb: true)

The arguments passed to `start_rspec`, represent the defaults you consider important for achieving a clean RSpec run.  If your particular project doesn't have a DB, or you don't need it prepared before each Rspec run, you can turn that step off by passing `prepare_db: false`.

Be careful about the steps you enable/disable inside the script file.  **The goal is to define steps that help people, with limited knowledge of the project, successfully run RSpec.**  It's best to have `bin/start_rspec` define the best way to run RSpec for newbies, then disable specific steps by passing in command line options on a per-run basis.  Run `bin/start_rspec --help` to see a list of available options.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/roberts1000/rspec_starter.

