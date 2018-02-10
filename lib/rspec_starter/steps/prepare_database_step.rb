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

      rebuild_cmd = "rake db:drop db:create db:migrate RAILS_ENV=test"
      print "[#{@runner.step_num}] Preparing the test database with '#{rebuild_cmd.rs_yellow}' ... "
      _stdin, _stdout, stderr = Open3.popen3(rebuild_cmd)
      output_array = prepare_output_array(stderr.readlines)

      @success_or_skipped = successful?(output_array)

      if @success_or_skipped
        puts "Success".rs_green
        puts output_array
      else
        puts "Fail".rs_red + "\n\n"
        puts output_array
        puts "\n\nThere was an error rebuilding the test database.  See the output above for details.".rs_red
        puts "or manually run '#{rebuild_cmd}' for more information.".rs_red
      end
    end

    private

    # Simply checking the exitstatus isn't good enough.  When rake aborts due to a bug, it will still
    # return a zero exit status.  We need to see if 'rake aborted!' has been written to the output.
    def successful?(output_array)
      return false if $CHILD_STATUS.exitstatus.nonzero?
      output_array.none? { |result| result.include? "rake aborted!" }
    end

    def prepare_output_array(array)
      (0..array.size - 1).each { |i| array[i] = "    #{array[i].strip}".rs_red }
      array
    end
  end
end
