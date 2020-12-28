module RspecStarter
  RSpec.describe StepContext do
    it "has a version number" do
      StepContext.new(environment: nil, id: 1, requested_args:"")
    end
  end
end
