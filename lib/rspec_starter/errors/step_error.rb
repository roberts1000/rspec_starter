module RspecStarter
  # This error is raised when execution should completely stop. The current step should be finalized before this
  # error is raised. Once this error is raised, RspecStarter will halt and report a non-zero exit status to the user.
  class StepError < StandardError
    def initialize(msg="")
      super
    end
  end
end
