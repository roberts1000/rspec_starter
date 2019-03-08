# Helper methods that can be used anywhere in RspecStarter.
module RspecStarter
  def self.helpers
    @helpers ||= Helpers.new
  end

  # A class that provides helper methods that can be used anywhere in RspecStarter.
  class Helpers
    def class_for_task_name(string_or_symbol)
      string_or_symbol.to_s.camelize.constantize
    end

    def project_is_rails_app?
      @project_is_rails_app ||= File.file?(File.join(Dir.pwd, 'config', 'application.rb'))
    end

    def project_is_rails_engine?
      return false unless project_has_lib_dir?

      Dir["#{Dir.pwd}/lib/**/*.rb"].each do |file|
        return true if File.readlines(file).detect { |line| line.match(/\s*class\s+.*<\s+::Rails::Engine/) }
      end
      false
    end

    def project_has_lib_dir?
      @project_has_lib_dir ||= Dir.exist?("#{Dir.pwd}/lib")
    end

    # Taken from https://stackoverflow.com/questions/11784109/detecting-operating-systems-in-ruby/13586108
    def operating_system_name
      @operating_system_name ||= begin
        host_os = RbConfig::CONFIG['host_os']
        case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          :windows
        when /darwin|mac os/
          :macosx
        when /linux/
          :linux
        when /solaris|bsd/
          :unix
        else
          :unknown
        end
      end
    end

    def is_linux?
      operating_system_name == :linux
    end

    def is_mac?
      operating_system_name == :maxosx
    end

    def xvfb_installed?
      @xvfb_installed ||= RspecStarter.which("xvfb-run")
    end

    def xvfb_not_installed?
      !xvfb_installed?
    end

    # This is ugly, but it gives us some added flexibility.  Users can invoke the rspec_starter method from any script or
    # executable.  This method attempts to find out the file name of the script/exectuable.
    #
    # This method may not return a pretty result in all cases, but it's decent if the user has defined a script in their project
    # (possibly in the bin folder, or root of the project).
    def starter_script_file_name
      caller.last.split(":")[0]
    end
  end
end
