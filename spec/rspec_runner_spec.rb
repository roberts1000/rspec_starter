require "spec_helper"

RSpec.describe RspecStarter do
  it "has a version number" do
    expect(RspecStarter::VERSION).not_to be nil
  end
end
