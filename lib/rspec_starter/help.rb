# Code that shows output when 'bin/start_rspec --help' or 'bin/start_rspec -h' is executed.
module RspecStarter
  def self.should_show_help?
    ARGV.any? { |option| option.include?("--help") || option.include?("-h") }
  end

  def self.show_help
    # Figure out the file name that invoked the rspec_starter helper and treat it as the name of the
    # script.  We install a bin/rspec_starter file, but the user could call it anything.
    script_name = helpers.starter_script_file_name
    colored_script_name = script_name.colorize(:light_blue)

    write_help_usage_section(script_name, colored_script_name)
    write_help_options_section(colored_script_name)
    write_help_examples_section(colored_script_name)

    exit(0)
  end

  def self.write_help_usage_section(script_name, colored_script_name)
    puts "Usage: #{colored_script_name} #{'[options] [options for RSpec]'.colorize(:light_blue)}\n"
    puts "       #{script_name} will look for its own options first then pass any remaining options to RSpec."
  end

  def self.write_help_options_section(colored_script_name)
    puts "\nOptions: (run #{'rspec --help'.colorize(:light_blue)} to see RSpec's options)"
    puts "       This list is computed dynamically based on the tasks that are enabled in the #{colored_script_name} file."

    max_length = @environment.options.all_task_switches.max_by(&:length).size

    @environment.options.all_task_options.each do |option|
      length = option.switch.length
      padding = max_length - length + 5 # 5 is the number of spaces past the longest swtich to start the description column
      puts "       #{option.switch.colorize(:light_blue)}#{' ' * padding}#{option.description}"
    end
  end

  def self.write_help_examples_section(colored_script_name)
    # rubocop:disable Metrics/LineLength
    puts "\nExamples:"
    puts "       #{colored_script_name} #{'spec/features'.colorize(:light_blue)} (only run specs in the specs/features folder)"
    puts "       #{colored_script_name} #{'spec/features/some_spec:53'.colorize(:light_blue)} (run the spec on line 53 of the spec/features_some_spec.rb file)"
    puts "       #{colored_script_name} #{'--no-xvfb'.colorize(:light_blue)} #{'spec/requests/some_spec'.colorize(:light_blue)} (don't start XVFB since it's not needed for request specs)"
    puts "       #{'SIMPLECOV_FORMATTER=rcov'.colorize(:light_blue)} #{colored_script_name} (use with environment variables)\n\n"
    # rubocop:enable Metrics/LineLength
  end
end
