module RspecStarter
  # TaskContext's are created to when parsing the RspecStater.start block. They hold the args and Task class name. They are
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

    def build_options
      options = super
      add_defaults_to_options(options)
      apply_args_to_options(options)
      apply_command_line_switches_to_options(options)
      options
    end

    def add_defaults_to_options(options)
      registered_options = environment.options.registered_task_option(@step_class)
      registered_options.each { |option| options.add(option.key, option.default) }
    end

    def apply_args_to_options(options)
      registered_options = environment.options.registered_task_option(@step_class)
      dsl_option_names = registered_options.select(&:is_dsl_option?).collect { |option| option.name.to_sym }
      @requested_args.each do |key, value|
        next unless dsl_option_names.include?(key)

        options.update(key, value, add_missing: false)
      end
    end

    def apply_command_line_switches_to_options(options)
      registered_options = environment.options.registered_task_option(@step_class)
      present_switches = environment.options.present_switches
      registered_options.each do |option|
        # The switch could be nil for the option, which means the step isn't registering a switch for this option. The step
        # developer just wants to register an option for the dsl (which is applied earlier).
        if option.switch
          options.update(option.key, !option.default, add_missing: false) if present_switches.include?(option.switch)
        end
      end
    end
  end
end
