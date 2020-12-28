require 'simplecov'
SimpleCov.start

require "bundler/setup"
require "rspec_starter"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Custom RSpec configuration is located in spec/support/init/rspec.rb.  This
# line is executed AFTER the `RSpec.configure` block above so
# spec/support/init/rspec.rb can can override any changes in this file.
Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }
