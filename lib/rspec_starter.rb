require 'active_support/core_ext/string/inflections'
require 'English'
require 'colorize'
require 'open3'
require 'rbconfig'

require 'rspec_starter/core_ext/string'

require 'rspec_starter/help'
require 'rspec_starter/helpers'
require 'rspec_starter/helpers/which'
require 'rspec_starter/option'
require 'rspec_starter/options'
require 'rspec_starter/step_options'
require 'rspec_starter/environment'

require "rspec_starter/version"
require "rspec_starter/errors/step_error"
require "rspec_starter/errors/step_stopper"

require 'rspec_starter/runner'
require 'rspec_starter/step_context'
require 'rspec_starter/step'
require 'rspec_starter/task_context'
require 'rspec_starter/task'
require 'rspec_starter/command_context'
require 'rspec_starter/command'

require 'rspec_starter/tasks/rebuild_rails_app_database'
require 'rspec_starter/tasks/remove_tmp_folder'
require 'rspec_starter/tasks/start_rspec'
require 'rspec_starter/tasks/verify_display_server'

require 'rspec_starter/legacy'

# Setup pry for development when running "rake console". Guard against load
# errors in production (since pry is only loaded as a DEVELOPMENT dependency
# in the .gemspec)
# rubocop:disable Lint/HandleExceptions
begin
  require "pry"
rescue LoadError
end
# rubocop:enable Lint/HandleExceptions

# The main entry point for the RspecStarter gem. The 'bin/start_rspec' file contains a block of code like this:
#
#   RspecStarter.start do
#     command "echo 'something'"
#     task :some_task_name
#     ... more tasks and commands ...
#   end
#
# The start method that is executed is show below. The call to 'instance_eval(&block)' below is the special sauce that
# makes 'self' equal the RspecStarter module inside the block.
module RspecStarter
  def self.start(defaults={}, &block)
    # If a block is missing, then the user is using the old method based starter.
    return invoke_legacy_starter(defaults) unless block_given?

    # Loads the information from the bin/start_rspec file and loads/parses the options. Provides info to the @runner.
    @environment = Environment.new(ARGV, &block)

    # Holds the step objects and executes them.
    @runner = Runner.new(@environment)

    # The bin/start_rspec file in the host application sets the APP_ROOT to the root folder of the host application.
    Dir.chdir APP_ROOT do
      # If we show help, exit and don't do anything else. We need to run the help in the context of the app root
      # so the help output can show file paths relative to where the user is running (and not relative to this gem).
      return show_help if should_show_help?

      begin
        @runner.run
      rescue StepError
        # The runner executes steps (which are tasks and commands). If a step reports a problem and the 'stop_on_problem' option
        # is set to 'true' (for a given step), the step will raise a StepError error. That is the signal that execution should
        # terminate immediately.
        exit(@runner.largest_exit_status)
      end

      # If we get here RSpec has been started and the rspec_starter's job is done.
      exit(0)
    end
  end
end
