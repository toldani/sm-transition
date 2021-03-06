class String
  # colorization
  def colorize(cc)
  	# symbols +, -, _, and * can precede color letter (bright, dim, underline, bold)
  	colors = {"k" => 0, "r" => 1, "g" => 2, "y" => 3, "b" => 4, "m" => 5, "c" => 6, "w" => 7}
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end
end