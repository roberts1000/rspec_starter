module RspecStarter
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
      @runner.app_uses_rails?
    end

    def execute
      return @success_or_skipped = true if should_skip?

      rebuild_cmd = "rake db:drop db:create db:migrate RAILS_ENV=test"
      print "[#{@runner.step_num}] Preparing the test database with '#{rebuild_cmd.rs_yellow}' ... "
      _stdin, _stdout, stderr = Open3.popen3(rebuild_cmd)
      error_msg_array = stderr.readlines

      if error_msg_array.empty?
        puts "Success".rs_green
        @success_or_skipped = true
      else
        puts "\n\n"
        puts error_msg_array
        puts "\n\nThere was an error rebuilding the test database.  See the output above for details.".rs_red
        puts "or manually run '#{rebuild_cmd}' for more information.".rs_red
        @success_or_skipped = false
      end
    end
  end
end
