# Rebuild the database for a rails application or a rails engine. This task honors the following command line options
#   --skip-db-prep    Causes the task to be skipped
class RebuildRailsAppDatabase < RspecStarterTask
  def self.description
    "Rebuild a Ruby on Rails application or engine database."
  end

  def self.register_options
    register_option default: false, switch: '--skip-db-prep',
      switch_description: "DO NOT prepare the Rails application database"
    register_option name: "command",
      default: "DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=test rake db:drop db:create db:schema:load",
      description: "A command string that is used to rebuild the database."
  end

  def should_skip?
    options.skip_db_prep || options.command.nil? || options.command.empty?
  end

  def starting_message
    "Running #{options.command.highlight}"
  end

  def execute
    if quiet?
      @stdout, @stderr, @status = Open3.capture3(options.command)
    else
      puts "\n\n"
      @verbose_command_passed = system options.command
      @status = $CHILD_STATUS
      print @starting_message
    end
    problem if command_failed?
  end

  def write_error_info
    puts @stdout
    puts @stderr
    puts "\n\nThere was an error rebuilding the test database.  See the output above for details " \
         "or manually run '#{options.command}' for more information.".colorize(:red)
  end

  private

  # Simply checking the exitstatus isn't good enough.  When rake aborts due to a bug, it will still
  # return a zero exit status.  We need to see if 'rake aborted!' has been written to the output.
  def command_failed?
    @status.exitstatus.nonzero? || (!@stderr.nil? && @stderr.include?("rake aborted!")) || @verbose_command_passed == false
  end
end
