require "spec_helper"

RSpec.describe "RspecStarter" do
  it "has a version number" do
    expect(RspecStarter::VERSION).to_not be_nil
  end
end
