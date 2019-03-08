# This module loads the legacy RspecStarter code that uses the non-block DSL. It will be removed in 2.0.0.
# The file is loaded when RspecStarter starts, but most of the legacy code is not loaded until the
# 'invoke_legacy_starter' method is called.
module RspecStarter
  def self.invoke_legacy_starter(defaults)
    require 'rspec_starter/legacy/legacy_runner'
    # puts "[DEPRECATION NOTICE] Your #{helpers.starter_script_file_name} file uses an old method for starting RSpec.\n" \
    #   "RspecStarter 1.6.0 introduced a new interface that is faster and more flexible.\n" \
    #   "To upgrade:\n" \
    #   "  1. Run 'rspec_starter --init' to install a new bin/start_rspec file.\n" \
    #   "  2. Your old bin/start_rspec will be renamed to bin/start_rspec.bak. If you customized\n" \
    #   "     this file, open it up and consider moving the changes to the new bin/start_rspec file.\n" \
    #   "     See https://github.com/roberts1000/rspec_starter for instructions on the new interface.\n".colorize(:yellow)
    LegacyRunner.new(defaults).run
  end
end
