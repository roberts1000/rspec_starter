# Add some ome simple colorization methods for formatting console output.
class String
  def highlight
    colorize(:light_blue)
  end

  def warning
    colorize(:yellow)
  end
end
