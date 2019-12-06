module RspecStarter
  # StepContext is an abstract class. Subclasses hold the information from the RspecStarter.start block when the block is parsed,
  # but they don't actually execute Steps. Their job is to instantiate Step objects, and bind the appropriate options to the
  # objects so they can execute correctly.
  class StepContext
    attr_reader :environment, :id, :requested_args

    def initialize(environment:, id:, requested_args:)
      @environment = environment
      @id = id
      @requested_args = requested_args
    end

    private

    def build_options
      options = StepOptions.new
      apply_global_options_to_options(options)
      options
    end

    def apply_global_options_to_options(options)
      options.add("quiet", step_class.default_quiet)
      options.add("stop_on_problem", step_class.default_stop_on_problem)
      options.add("rspec_args_string", environment.options.rspec_args_string)
    end
  end
end
