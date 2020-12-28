module RspecStarter
  # TaskContext's are created to when parsing the RspecStater.start block. They hold the ARGS and Task class name. They are
  # asked to create instances of Task subclasses from this information when it is time to execute. The also resolve the options
  # that each Task is allowed to access.
  class TaskContext < StepContext
    attr_reader :step_class

    def initialize(environment:, id:, step_class:, requested_args:)
      super(environment: environment, id: id, requested_args: requested_args)

      @step_class = step_class
    end

    def instantiate(runner)
      @step_class.new(@id, runner, build_options)
    end

    def is_task?
      true
    end

    def is_command?
      false
    end

    private

    def registered_task_options
      environment.options.registered_task_option(@step_class)
    end

    def build_options
      options = super
      add_task_option_defaults(options)
      apply_start_block_option_overrides(options)
      apply_command_line_switch_overrides(options)
      options
    end

    # Each Task can define options that are unique to the task, along with default values for those options. Add those
    # options and values now. (The values may be overridden by the user.)
    def add_task_option_defaults(options)
      registered_task_options.each { |option| options.add(option.key, option.default) }
    end

    # Users can specify options for each task inside their project's "start" block. These options can override the default
    # value for the global options that all tasks have, or the task specific options that a task defines by calling
    # register_task_option. If the user tries to define an option that the task doesn't understand, it is ignored.
    def apply_start_block_option_overrides(options)
      @requested_args.each { |option_name, option_value| options.update(option_name, option_value, add_missing: false) }
    end

    # Command line switches can also affect options. Adjust an options that are impacted by command line switches that are
    # present.
    def apply_command_line_switch_overrides(options)
      present_switches = environment.options.present_switches
      registered_task_options.each do |option|
        # present_switches is a list of all valid switches that have been supplied by the user.
        if option.switch && present_switches.include?(option.switch)
          options.update(option.key, !option.default, add_missing: false)
        end
      end
    end
  end
end
