module RspecStarter
  # CommandContext's are created to when parsing the RspecStater.start block. They hold the args for Commands. They are
  # asked to create instances of Command from this information when it is time to execute. The also resolve the options
  # that each Command is allowed to access.
  class CommandContext < StepContext
    attr_reader :command_string

    def initialize(environment:, id:, command_string:, requested_args:)
      super(environment: environment, id: id, requested_args: requested_args)

      @command_string = command_string
    end

    def instantiate(runner)
      Command.new(@id, runner, @command_string, build_options)
    end

    def step_class
      Command
    end

    def is_task?
      false
    end

    def is_command?
      true
    end

    private

    def build_options
      options = super
      apply_args_to_options(options)
      options
    end
  end
end
