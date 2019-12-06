module RspecStarter
  # This error is raised when a step wants to gracefully stop execution. It does not prevent later steps from running.
  # It only ends on the current step execution.
  class StepStopper < StandardError
    def initialize(msg="")
      super
    end
  end
end
