require 'pathname'
require 'open3'
require_relative 'core_ext/string'
require_relative 'which'
require_relative 'help'
require_relative 'steps/step'
require_relative 'steps/verify_xvfb_step'
require_relative 'steps/prepare_database_step'
require_relative 'steps/remove_tmp_folder_step'
require_relative 'steps/invoke_rspec_step'

module RspecStarter
  # This is a simple class that encapulates the process of running RSpec.  When a Runner is created, it creates a set of
  # steps that will be executed, in order, when the 'run' method is invoked.  Each step encapsulates an action that can be
  # taken to help invoke Rspec.  Steps are typically independent do not depend on information from other steps.  However
  # this is not a hard rule.  If more complex steps are needed, feel free to create them.  Each steps knows about the main
  # runner object, so the runner object is a good place to store shared info.
  class Runner
    include Help
    attr_reader :xvfb_installed, :step_num, :steps

    def initialize(defaults)
      @steps = []
      @step_num = 1
      @xvfb_installed = RspecStarter.which("xvfb-run")
      @prep_db_step = PrepareDatabaseStep.new(defaults, self)
      @run_rspec_step = InvokeRspecStep.new(defaults, self)
      @steps << VerifyXvfbStep.new(defaults, self)
      @steps << @prep_db_step
      @steps << RemoveTmpFolderStep.new(defaults, self)
      @steps << @run_rspec_step
    end

    def run
      return show_help if should_show_help? # If we show help, exit and don't do anything else.

      @steps.each do |step|
        next unless step.should_execute?
        step.execute
        @step_num += 1
        break if step.failed?
      end

      finalize_exit
    end

    def project_is_rails_app?
      File.file?(File.join(Dir.pwd, 'config', 'application.rb'))
    end

    def project_is_rails_engine?
      return false unless project_has_lib_dir?
      Dir["#{Dir.pwd}/lib/**/*.rb"].each do |file|
        return true if File.readlines(file).detect { |line| line.match(/\s*class\s+.*<\s+::Rails::Engine/) }
      end
      false
    end

    def project_has_lib_dir?
      Dir.exist?("#{Dir.pwd}/lib")
    end

    def operating_system_name
      result = `uname`
      return 'Linux' if result.include?('Linux')
      return 'MacOS' if result.include?('Darwin')
      'Unknown'
    end

    def is_linux?
      operating_system_name == 'Linux'
    end

    def is_mac?
      operating_system_name == 'MacOS'
    end

    def xvfb_installed?
      @xvfb_installed
    end

    def finalize_exit
      exit(1) if @run_rspec_step.rspec_exit_status.nonzero?
      exit(1) if @prep_db_step.exit_status.nonzero?
      exit(0)
    end
  end
end
