# rspec_starter

rspec_starter is a Ruby gem that simplifies the process of running RSpec. Instead of running `bundle exec rspec`, developers run a script that includes predefined steps to execute while starting RSpec. The steps can be anything from removing the projects `tmp` folder to doing a full rebuild of the database prior to starting RSpec.

rspec_starter also helps eliminate differences between operating systems. For example, MacOS provides it's own display server for running feature tests while Linux operating systems may need to start a display sever, like XVFB. rspec_starter can inspect the OS and start the display server if necessary.

rspec_starter currently works natively for Rails applications, Rails Engines and raw ruby applications/gems that are not database dependent. However, rspec_starter is flexible and you can add your own tasks to support other types of projects.

## Versioning Strategy

Releases are versioned using [SemVer 2.0.0](https://semver.org/spec/v2.0.0.html) with the following caveats:

1. Support for a Ruby version, that reaches EOL, is removed in a major or minor release.
1. Support for a Ruby on Rails version, that reaches EOL, is removed in a major or minor release.

## Supported Ruby Versions

3.2.0+

## Installation

### Rails Applications & Rails Engines

Add this line to the `Gemfile` of your Rails application or Rails Engine:

```ruby
group :development do
  gem 'rspec_starter', require: false
end
```

You do not need to add rspec_starter to the `:test` group since rspec_starter doesn't execute while RSpec runs. Its work is done once RSpec starts.

Next, execute:

    $ bundle

Then run the installer

    $ rspec_starter --init

The installer creates a `bin/start_rspec` that you will use to start RSpec. You can rename the file to anything you want.

## Basic Usage

`cd` into the root of your project and invoke the script.

    $ bin/start_rspec

The `bin/start_rspec` file executes a series of "steps" (more on this later) and eventually starts RSpec. Output from RSpec is displayed to the console as normal.

You can pass command line arguments to rspec_starter. To see the full list, type `bin/start_rspec --help`.  When you pass arguments, rspec_starter first checks if any of them are specific to rspec_starter.  It processes those arguments and takes action.  Any remaining arguments are saved and passed to RSpec when RSpec is started. You can use all the normal RSpec command line options, except for `--help` and `-h` (rspec_starter assumes you want help for rspec_starter instead of rspec). rspec_starter will happily forward them on.  For example, if you only want to execute the feature specs in your project, simply do what you would normally do for RSpec:

    $ bin/start_rspec spec/features

## Customizing the bin/start_rspec file

The `bin/start_rspec` file was made to be edited. When you ran the `rspec_starter --init` command, it installed a basic command for your project that looked something like this:

```ruby
RspecStarter.start do
  task :verify_display_server
  task :remove_tmp_folder
  task :rebuild_rails_app_database
  task :start_rspec
  command "echo 'Done Diggity Done!'"
end
```

#### Steps

At it's heart, rspec_starter is just a block that lists a series of "steps" that are executed in **top down order**. rspec_starter provides two kinds of steps:

1. `command` - A "command" is the most basic kind of "step" in rspec_starter. It accepts a string and passes that string to the ruby `system` command. It can be used to run shell commands or scripts.
1. `task` - A "task" is just a ruby class that implements an `execute` method. What you do in that `execute` method is up to you. rspec_starter provides a couple built-in tasks that perform various actions that are useful when running RSpec. The list of available task are defined below. You can also easily create your own.

#### Step Options

Any options that you add to steps inside the block, become available to the task.

```ruby
RspecStarter.start do
  task :verify_display_servr, foo: :bar
  task :remove_tmp_folder
  task :rebuild_rails_app_database, command: "RAILS_ENV=test rake db:drop db:create db:schema:load", quiet: false
  task :start_rspec, quiet: true
end
```

Tasks ignore options unless they are specifically coded to look for them. For example, the `foo: :bar` in the above example has no affect on the `verify_display_server` task while the `command` option on the `rebuild_rails_app_database` changes the command that is executed.

All steps allow you to specify these options when you call the `command` or `task` helpers:

1. `quiet` - Direct the step to generate as little output as possible when it executes. It's up to the step to determine what this means for the step and the step may choose to ignore it. If you do not specify a value, a `command` or `task` will pick a default that it prefers. If the `command` or `task` triggers an error while it is running, it will dump the error output to the screen if it was running quietly.
1. `stop_on_problem` - Direct rspec_stater to stop everything if a particular step fails. Some steps may only show information, and if they fail, you may not want to stop RSpec from running. If you want to ensure a step failure causes rspec_stater to stop, then set `stop_on_problem: true`. If you do not specify a value, steps will chose their preferred value.

## Commands

Commands are steps that pass a string to the Ruby `system` method. Commands are defined in the following manner

```ruby
RspecStarter.start do
  command "echo 'This will execute, but not display output of the command"
  command "echo 'This will execute, and display the output of the command", quiet: false
end
```

rspec_starter tries to keep output concise so command output is hidden by default. If you want to see the output of a command, add the `quiet: false` option.

## Tasks

#### Built-in Tasks

rspec_starter provides the following built-in tasks:

1. `verify_display_server` - Verify that Linux users have XVFB installed and Mac OS users do not.
1. `remove_tmp_folder` - Delete the project's `tmp` folder.
1. `rebuild_rails_app_database` - Rebuild the test database for a Ruby on Rails application. By default, the seed files are not loaded. The goal is to have a completely empty database.
1. `start_rspec` - Run RSpec.

You can find the code for rspec_starter's built-in `tasks` at ../../lib/rspec_starter/tasks.

#### Custom Tasks

The default tasks provided by rspec_starter are just subclasses of the `RspecStarterTask` class. You can define your own subclasses anywhere and load them. A simply way to get started is to define the classes in the `bin/start_rspec` file, before `RspecStarter.start` is called.

```ruby
class MyTask < RspecStarterTask
  # [OPTIONAL] This is an optional method. If you define it, you can add command line options to the
  # root bin/start_rspec starter command and arguments to the task steps inside the
  # 'RspecStarter.start' block. You can access the values at runtime by calling 'options'.
  # Be careful not to add a switch that RSpec itself uses. rspec_starter will use it, but it will
  # not forward it to RSpec.
  def self.register_options
    # The following registration lets users call
    #
    #   bin/start_rspec --skip-my-task
    #
    # and inside the start block they can do
    #
    #   RspecStarter.start do
    #     task :my_task, skip_my_task: true/false
    #   end
    #
    # register_option takes the following options
    #
    #   name        - The argument name for the task option'.
    #   default     - The default value when the argument is not specified on the 'task' step.
    #   switch      - The string the user specifies with the 'bin/start_rspec' command. Switches
    #                 always return true or false.
    #   description - The information to show when 'bin/start_rspec --help' is run.
    #
    # There are some rules that must be followed when registering the option:
    #
    #   1. You must specify either "name:", "switch:" or both.
    #   2. If you specify both, "switch:" must be similiar to 'name:'. For example, if the name is
    #      "skip_my_task", the switch must be --skip-my-task (-skip-my-task works too). Internally,
    #      the hypens in the switch name are converted to underscores so you can access it as a
    #      method on the options object inside the task.
    #   3. Switch names must start with "--" or "-".
    #   4. If "switch:" is specified, "default:" must be set to true or false. If the user does not
    #      use the switch in the commandline, the default value is returned. If the user
    #      specifies the switch, !default is returned.
    #
    register_option name: "skip_my_task", default: false, switch: '--skip-my-task',
      description: "Skip the task"
  end

  # [OPTIONAL] This is an optional method. Let subsequent steps run if this task runs into a problem.
  # This value can be overridden in the applications bin/start_rspec file if the user adds
  # 'stop_on_problem: true' to the task line.
  def self.default_stop_on_problem
    false
  end

  # [OPTIONAL] This is an optional method. Specify if the task likes to run quietly or not. This will
  # only set the 'quiet' flag on the task. It is up to you to check the quiet flag in the `execute`
  # method and do something quietly or not.
  def self.default_quiet
    false
  end

  # [OPTIONAL] This is an optional method. If you want your task to be skipped under certain conditions,
  # add the logic here. The task is fully initialized at this point and you have access to the
  # 'options' object and any arguments that are added to the `task` helper inside the
  # `RspecStarter.start` block.
  def should_skip?
    options.skip_my_task
  end

  # The string that is returned from this method is displayed just before your task starts to run. It
  # should be brief and describe what the task is doing.
  def starting_message
    "Some string"
  end

  # This is the main run method. Do whatever you want your task to do here.
  def execute
    # Call the 'problem' method if the command ran into an error.
    problem if something_went_wrong

    # You can call the 'success' method if successful, but this is optional. rspec_starter will
    # assume the task was successful if `problem` wasn't called.
    success
  end

  # [OPTIONAL] This is an optional method. When your task runs in quiet mode, it may not write error
  # output to the screen if there's a problem. This method is called only when you call the `problem`
  # method during execution (or if there's a general error raised). You can write any error/debug
  # information that you find helpful.
  def write_error_info
  end
end
```

Once your custom task class is created, add it to the `RspecStarter.start` block:

```ruby
RspecStarter.start do
  #... tasks or commands above ...
  task :my_task
  # ... tasks or commands below ...
  task :start_rspec
end
```

When you add the `task` line, convert your class to lowercase and user underscores for word separators. In this example, the `MyTask` class became `:my_task` when it was used inside the start block.

That's it. rspec_starter will find your class, and call the `execute` at the appropriate time.

## Command line options

Run `bin/start_rspec --help` to see a list of command line options. Command line options override settings that are present in the `bin/start_rspec` file, or hard-coded defaults inside the Task/Command code.

## Contributing

Bug reports and pull requests are welcome on the rspec_starter [issues](https://github.com/roberts1000/rspec_starter) page.
