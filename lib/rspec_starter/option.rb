module RspecStarter
  # Option objects hold the information that Step subclasses want to register as options.
  class Option
    attr_reader :name, :default, :description, :key, :owner, :switch, :switch_description

    def initialize(name:, default:, description: "", owner:, switch:, switch_description: "")
      @owner = owner
      @switch = switch
      @switch_description = switch_description
      @simplified_switch = switch.nil? ? nil : self.class.simplified_switch_name(switch)
      @description = description
      @default = default
      self.name = name
      @key = name || @simplified_switch
      validate
    end

    def name=(value)
      @name = value.nil? ? nil : value.to_s
    end

    # Remove leading hyphens
    # Convert remaining hyphens to underscores
    # Undercase
    def self.simplified_switch_name(switch)
      switch.sub(/^-*/, "").sub("-", "_").underscore
    end

    # Does this option apply to the DSL inside the RspecStarter.start block. If so, users can use it like this:
    #   RspecStarter.start do
    #     task :foo, option_name_here: "some_value"
    #   end
    def is_dsl_option?
      !name.nil?
    end

    private

    def validate
      validate_name_has_no_hyphens
      validate_switch_starts_with_hyphens
      validate_name_or_switch_present
      validate_default_is_true_false_for_switch
      validate_switch_is_like_name
    end

    def validate_name_has_no_hyphens
      return unless name
      return unless name.include?("-")

      raise "#{owner.name}#register_options is trying to register #{name}. Option names should not include hyphens"
    end

    def validate_switch_starts_with_hyphens
      return unless switch
      return unless switch[0] != "-" || switch[2] == "-"

      raise "#{owner.name}#register_options is trying to register switch #{switch}. The switch name must start with '--' or '-'"
    end

    def validate_name_or_switch_present
      return unless switch.nil? && name.nil?

      raise "#{owner.name}#register_options is trying to create an option but 'name:' or 'switch:' are not specified. " \
        "At least one must be specified."
    end

    def validate_default_is_true_false_for_switch
      return unless switch && ![true, false].include?(default)

      raise "#{owner.name}#register_options is trying to create an option for switch #{switch}. Options with switches " \
        "can only return true/false. Set the 'default' argument to true or false for the option."
    end

    def validate_switch_is_like_name
      return unless  !switch.nil? && !name.nil?
      return if name == @simplified_switch

      raise "#{owner.name}#register_options is trying to create an option with name #{name} and switch #{switch}. " \
        "The switch must be the same as the name when hyphens are converted to underscores and leading hyphens " \
        "are removed."
    end
  end
end
