module RspecStarter
  # The steps that destorys and rebuilds the DB before running RSpec.
  class PrepareDatabaseStep < RspecStarter::Step
    def initialize(defaults, runner)
      super(runner)
      @prepare_database = defaults.fetch(:prepare_db, true)
      @relevant_options << '--no-prep-db'
      @user_wants_to_skip = ARGV.any? { |option| option.include?("--no-prep-db") }
      @success_or_skipped = nil # Will be updated once step executes
    end

    def failed?
      !@success_or_skipped
    end

    def should_execute?
      return false if @user_wants_to_skip
      return false unless @prepare_database
      @runner.project_is_rails_app? || @runner.project_is_rails_engine?
    end

    def execute
      return @success_or_skipped = true if should_skip?

      rebuild_cmd = rebuild_command
      print "[#{@runner.step_num}] Preparing the test database with '#{rebuild_cmd.colorize(:light_blue)}' ... "
      _stdout, stderr, _status = Open3.capture3(rebuild_cmd)
      @success_or_skipped = successful?(stderr)

      if @success_or_skipped
        puts "Success".colorize(:green)
      else
        puts "Fail".colorize(:red) + "\n\n"
        puts stderr
        puts "\n\nThere was an error rebuilding the test database.  See the output above for details.".colorize(:red)
        puts "or manually run '#{rebuild_cmd}' for more information.".colorize(:red)
      end
    end


    private

    def rebuild_command
      "rake db:drop db:create db:migrate RAILS_ENV=test"
    end

    # Simply checking the exitstatus isn't good enough.  When rake aborts due to a bug, it will still
    # return a zero exit status.  We need to see if 'rake aborted!' has been written to the output.
    def successful?(stderr)
      return false if $CHILD_STATUS&.exitstatus&.nonzero?
      !stderr.include?("rake aborted!")
    end
  end
end
