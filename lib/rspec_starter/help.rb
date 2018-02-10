module RspecStarter
  # Method that support the help option on the bin/start_rspec script.
  module Help
    def should_show_help?
      ARGV.any? { |option| option.include? "--help" }
    end

    def show_help
      # Figure out the file name that invoked the rspec_starter helper.  This is the name of the script; it be called anything.
      script_name = calling_file_name
      puts "Usage: #{script_name.rs_yellow} #{'[options] [options for RSpec]'.rs_yellow}\n"
      puts "       #{script_name} will look for its own options first then pass any remaining options to rspec"

      puts "\nOptions: (run 'rspec --help' to see RSpec's options)"
      puts "       #{'--no-xvfb'.rs_yellow}   DO NOT run XVFB (this can speed up RSpec when running tests that don't need XVFB)"
      puts "       #{'--no-prep'.rs_yellow}   DO NOT prepare the test database (can speed up testing if you know the DB is clean)"

      puts "\nExamples:"
      puts "       #{script_name.rs_yellow} #{'spec/features'.rs_yellow} (only run specs in the specs/features folder)"
      # rubocop:disable Metrics/LineLength
      puts "       #{script_name.rs_yellow} #{'spec/features/some_spec:53'.rs_yellow} (run the spec on line 53 of the spec/features_some_spec.rb file)"
      puts "       #{script_name.rs_yellow} #{'--no-xvfb'.rs_yellow} #{'spec/requests/some_spec'.rs_yellow} (don't start XVFB since it's not needed for request specs)"
      # rubocop:enable Metrics/LineLength
      puts "       SIMPLECOV_FORMATTER=rcov #{script_name.rs_yellow} (use with environment variables)\n"
    end

    # This is ugly, but it gives us some added flexibility.  Users can invoke the rspec_starter method from any script or
    # executable.  This method attempts to find out the name of the script/exectuable.
    # "caller" returns the method stack, and because of the location of this file in the gem, we happen to be the 4th item in the
    # the array (hence "caller[3]" below).
    #
    # This method may not return a pretty result in all cases, but it's decent if the user has defined a script in their project
    # (possibly in the bin folder, or root of the project).
    def calling_file_name
      # rubocop:disable Performance/Caller
      caller[3].split(":")[0]
      # rubocop:enable Performance/Caller
    end
  end
end
