module RspecStarter
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
