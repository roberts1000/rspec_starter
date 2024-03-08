module RspecStarter
  # Manages the option registration process for the Step subclasses.
  # Holds raw option information so it can organized when steps run.
  class Options
    attr_reader :present_switches, :registered_task_options, :rspec_args_string

    def initialize(environment, args)
      @environment = environment
      # These are the ARGV args that are passed to the command line.
      @command_line_args = args
      # Task classes that are used in the RspecStarter.start block: VerifyDisplayServer, StartRspec, etc...
      @task_classes = environment.unique_task_classes
      # The options that each Task wants to use.
      @registered_task_options = {}

      # Tasks register the command line switches they care about and RspecStarter has some global switches that it uses. This
      # holds the list of switches that the user provided that match a task switch or a global switch. If the user doesn't
      # supply a switch, or supplies a switch that nobody cares about, this will be an empty list.
      @present_switches = nil

      load_registered_task_options
      initialize_present_switches

      # The args that should be passed to rspec when it starts.
      @rspec_args_string = nil
      initialize_rspec_args_string
    end

    # If 'switch' is given, the option can only return 'true' or 'false'. 'default' must be set to 'true' or 'false'. When
    # the switch isn't specified the user, the default (which must be true/false) is return. When the user specifies the default
    # !default is returned.

    # If switch is not given, default an be set to anything.

    # If name isn't specified, this option is only a commandline switch.
    # If name is specified, this option can be used inside the start block on a task.
    def register_task_option(klass, name: nil, default: nil, description: "", switch: nil, switch_description: "")
      new_option = RspecStarter::Option.new(name: name, default: default, description: description, owner: klass, switch: switch,
        switch_description: switch_description)
      @registered_task_options[klass] << new_option
    end

    def all_task_options
      hash = {}
      @registered_task_options.each_value do |options|
        options.each do |option|
          hash[option.switch] = option unless hash.has_key?(option.switch)
        end
      end

      list = []
      hash.each_value { |option| list << option }
      list
    end

    def all_switches
      (global_switches + all_task_switches).sort
    end

    def global_switches
      ['--help', '-h']
    end

    def all_task_switches
      list = Set.new
      @registered_task_options.each_value do |options|
        options.each { |option| list << option.switch unless option.switch.nil? }
      end
      list.to_a
    end

    def registered_task_option(task_class)
      @registered_task_options[task_class]
    end

    private

    def initialize_rspec_args_string
      list = @command_line_args.dup
      all_switches.each { |switch| list.delete(switch) }
      @rspec_args_string = list.join(" ")
    end

    def load_registered_task_options
      # Give each step class the ability to register options that we should know about.
      @task_classes.each do |klass|
        @registered_task_options[klass] = []
        klass.provide_options_to(self)
      end
    end

    def initialize_present_switches
      @present_switches = all_switches.select { |switch| @command_line_args.include?(switch) }.to_a
    end
  end
end
