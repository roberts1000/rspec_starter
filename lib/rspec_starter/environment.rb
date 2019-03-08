module RspecStarter
  # Load the environment for RspecStarter.
  class Environment
    attr_reader :options

    # &start_block is the start block from the host application's bin/start_rspec file. It looks like this:
    #
    #  RspecStarter.start do
    #    command "something"
    #    task :task_one
    #    command "something"
    #    task :task two
    #    ... more commands and tasks...
    #  end
    def initialize(args, &start_block)
      @next_id = 0
      @step_info = {}

      load_step_info(&start_block)

      @options = Options.new(self, args, &start_block)
      # This will lazily load once execution starts.
    end

    def step_contexts
      @step_info.values
    end

    def unique_task_classes
      @step_info.values.select(&:is_task?).collect(&:step_class).uniq
    end

    def command(string, **args)
      step_id = next_id
      @step_info[step_id] = CommandContext.new(environment: self, id: step_id, command_string: string, requested_args: args)
    end

    def task(task_name, **args)
      step_id = next_id
      klass = RspecStarter.helpers.class_for_task_name(task_name)
      @step_info[step_id] = TaskContext.new(environment: self, id: step_id, step_class: klass, requested_args: args)
    end

    private

    def next_id
      @next_id += 1
    end

    def load_step_info(&start_block)
      # This evaluates the start block and sets 'self' to an instance of Environment. The 'command' and 'task' methods
      # in this class capture the 'command' and 'task' calls in the block. From there, we can determine the Steps classes that the
      # user is trying to load.
      instance_eval(&start_block)
    end
  end
end
