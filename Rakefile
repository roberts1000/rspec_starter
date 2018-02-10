require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

# Adds the ability to run 'rake console' in the terminal and have a console
# that already knows about the gem
task :console do
  exec "pry -r rspec_starter -I ./lib"
  # exec "irb -r didit_rails_framework -I ./lib"
end
