module RspecStarter
  # Commands are steps that execute shell scripts or shell commands. They can be created using the command method
  # inside the RspecStarter.start block. Commands execute quietly unless you specifically set 'quiet: false'.
  #
  #   RspecStarter.start do
  #     command "echo 'Done'"
  #     command "echo 'This command shows the echo'", quiet: false
  #   end
  #
  class Command < RspecStarterStep
    attr_accessor :status, :stderr, :stdout

    def initialize(id, runner, command_string, options)
      super(id, runner, options)
      @command_string = command_string
    end

    def self.default_quiet
      true
    end

    def print_starting_message
      print "Executing #{colored_command_string} ..." + (quiet? ? "" : "\n")
    end

    def execute
      if quiet?
        @stdout, @stderr, @status = Open3.capture3(@command_string)
      else
        @verbose_command_passed = system(@command_string)
        @status = $CHILD_STATUS
        print "Executed #{colored_command_string} -"
      end

      problem(exit_status: @status.exitstatus) if command_failed?
    end

    private

    def initialize_name
      @name = :command
    end

    def write_error_info
      puts @stdout
      puts @stderr
      puts "There was an error running '#{@command_string}'. It returned with exit status #{@status.exitstatus}.\n" \
           "See the output above for details or manually run the command for more information.".colorize(:red)
    end

    def colored_command_string
      @command_string.colorize(:light_blue)
    end

    def command_failed?
      @status.exitstatus > 0 || @verbose_command_passed == false
    end
  end
end
