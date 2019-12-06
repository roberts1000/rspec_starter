module RspecStarter
  # The step that removes the tmp folder.
  class RemoveTmpFolderStep < RspecStarter::Step
    def initialize(defaults, runner)
      super(runner)

      @remove_tmp_folder = defaults.fetch(:remove_tmp, true)
      @runner = runner
      @relevant_options << "--no-remove-tmp"
      @user_wants_to_skip_removal = ARGV.any? { |option| option.include?("--no-remove-tmp") }
      @success_or_skipped = nil # Will be updated once step executes
    end

    def failed?
      !@success_or_skipped
    end

    def should_execute?
      return false if @user_wants_to_skip_removal

      @remove_tmp_folder
    end

    def execute
      return @success_or_skipped = true unless should_execute?

      existed_before = tmp_folder_exists?

      print "[#{@runner.step_num}] Removing #{'tmp'.colorize(:light_blue)} folder ... "
      system "rm -rf tmp/"

      if tmp_folder_exists?
        @succss_or_skipped = false
        puts "Failed (The tmp folder could not be removed.)".red
      else
        @success_or_skipped = true
        info = existed_before ? "" : " (the tmp folder didn't exist)"
        puts "Success!!#{info}".colorize(:green)
      end
    end

    def tmp_folder_exists?
      File.exist?(File.join(Dir.pwd, "tmp"))
    end
  end
end
