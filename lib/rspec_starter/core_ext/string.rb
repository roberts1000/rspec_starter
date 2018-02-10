# Add some ome simple colorization methods for formatting console output.
# Prefix methods with rs_ so they don't collide with other gems.
class String
  def rs_colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end
end
