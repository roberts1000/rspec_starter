module RspecStarter
  # Abstract super class for a step.
  class Step
    attr_reader :relevant_options

    def initialize(runner)
      @runner = runner
      @relevant_options = []
    end

    def should_skip?
      !should_execute?
    end
  end
end
