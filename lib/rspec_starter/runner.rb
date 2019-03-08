module RspecStarter
  # This class implements the main control loop that processes steps. It maintains a list of steps and executes
  # each one. Steps can be skipped if command line options, or other options dictate turn off the step.
  class Runner
    attr_reader :environment

    def initialize(environment)
      @environment = environment
      @steps = @environment.step_contexts.collect { |step_context| step_context.instantiate(self) }
    end

    def run
      @steps.each do |step|
        next if step.should_skip?

        print "[#{step.id}] "
        step.run
      end
    end

    def largest_exit_status
      @steps.inject(0) do |max, step|
        # If a step doesn't execute, it's exit_status will be nil.
        current = step.exit_status || 0
        max > current ? max : current
      end
    end
  end
end
