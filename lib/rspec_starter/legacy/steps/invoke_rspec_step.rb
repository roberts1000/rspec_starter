module RspecStarter
  # The step that actually starts the RSpec.
  class InvokeRspecStep < RspecStarter::Step
    attr_reader :rspec_exit_status

    def initialize(defaults, runner)
      super(runner)
      @allow_xvfb = defaults.fetch(:allow_xvfb, true)
      @relevant_options = ["--no-xvfb"]
      @success_or_skipped = nil # Will be updated once step executes
      @rspec_exit_status = nil # Will be updated once step executes
      @user_wants_to_skip_xvfb = ARGV.any? { |option| option.include?("--no-xvfb") }
      init_rspec_options
    end

    def init_rspec_options
      step_options = []
      @runner.steps.each { |step| step_options.concat(step.relevant_options) }
      @rspec_options = ARGV - step_options.to_a
    end

    def should_execute?
      true
    end

    def failed?
      !@success_or_skipped
    end

    def execute
      cmd = command
      cmd = "#{cmd} #{@rspec_options.join(' ')}" unless @rspec_options.empty?
      puts "[#{@runner.step_num}] Running specs with '#{cmd.colorize(:light_blue)}' ...\n\n"
      system cmd
      @rspec_exit_status = $CHILD_STATUS.exitstatus
      @success_or_skipped = true
    end

    # Returns a string that will either be 'xvfb-run bundle exec rspec' or 'bundle exec rspec'
    def command
      base = "bundle exec rspec"
      return base if @runner.is_mac?
      return base unless @allow_xvfb
      return base if @user_wants_to_skip_xvfb
      @runner.xvfb_installed? ? "xvfb-run #{base}" : base
    end
  end
end
