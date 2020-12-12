# The step that actually starts the RSpec.
class StartRspec < RspecStarterTask
  def self.description
    "Start RSpec."
  end

  def self.register_options
    register_option name: "skip_display_server", default: false, switch: '--skip-display-server',
                    switch_description: "DO NOT check for a display server",
                    description: "true/false to enable/disable starting the display server"
    register_option name: "command", default: "bundle exec rspec",
                    description: "A command string that is used to start RSpec."
  end

  def self.default_quiet
    false
  end

  def initialize(id, runner, options)
    super

    # Updated once task executes
    @command = nil
    @status = nil
    @stdout = nil
    @stderr = nil
  end

  def starting_message
    "Running specs with '#{command.colorize(:light_blue)}'"
  end

  def execute
    if quiet?
      print @starting_message
      @stdout, @stderr, @status = Open3.capture3(@command)
    else
      puts "\n\n"
      @verbose_command_passed = system @command
      @status = $CHILD_STATUS
      print @starting_message
    end

    problem(exit_status: @status.exitstatus) if rspec_failed?
  end

  private

  def rspec_failed?
    @status.exitstatus > 0 || @verbose_command_passed == false
  end

  def command
    @command ||= determine_command
  end

  def determine_command
    cmd = enhanced_command
    options.rspec_args_string.empty? ? cmd : "#{cmd} #{options.rspec_args_string}"
  end

  # Returns a string that will either be 'xvfb-run bundle exec rspec' or 'bundle exec rspec'
  def enhanced_command
    return options.command if RspecStarter.helpers.is_mac? || options.skip_display_server

    RspecStarter.helpers.xvfb_installed? ? "xvfb-run #{options.command}" : options.command
  end
end
