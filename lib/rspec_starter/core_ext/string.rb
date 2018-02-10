# Add some ome simple colorization methods for formatting console output.
# Prefix methods with rs_ so they don't collide with other gems.
class String
  def rs_colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def rs_red
    rs_colorize(31)
  end

  def rs_green
    rs_colorize(32)
  end

  def rs_yellow
    rs_colorize(33)
  end
end
