module RspecStarter
  # StepOptions is like an OpenStruct. It lets us add getters and setters to an object dynamically. It's used to hold the
  # options and values that uses specify on the commandline, and inside the RspecStarter.start bock. We used this custom class
  # instead of an OpenStruct to avoid the performance issues associated with OpenStruct and to give the ability to add additional
  # methods when needed.
  class StepOptions
    def add(key, value)
      instance_variable_set("@#{key}", value)
      self.class.define_method(key.to_s) do
        instance_variable_get("@#{key}")
      end
    end

    def update(key, value, add_missing: true)
      return instance_variable_set("@#{key}", value) if respond_to?(key)

      add(key, value) if add_missing
    end
  end
end
