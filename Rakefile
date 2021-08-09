require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Start a pry console with rspec_starter loaded."
task :console do
  exec "pry -r rspec_starter -I ./lib"
  # exec "irb -r didit_rails_framework -I ./lib"
end
