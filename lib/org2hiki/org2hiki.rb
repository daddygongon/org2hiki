# frozen_string_literal: true
# convert org formatted lines to hiki
class ToHiki
  def initialize()
    @in_example = false
    @outputs = []
  end

  # converter
  def convert(lines)
    lines.split(/\n/).each do |line|
      next if check_block?(line)
      line = check_in line
      line = check_head line
      @outputs << line
    end
    @outputs.join("\n")
  end

  private

  def check_head(line)
    return line if line == ""
    m = []
    if m = line.match(/^(\*+) (.+)$/)
      return "!" * m[1].size + " #{m[2]}"
    elsif m = line.match(/^(\s*)\d\. (.+)$/)
      return "#" * (m[1].size / 3 + 1) + " #{m[2]}"
    elsif m = line.match(/^- (.+) :: (.+)$/)
      return ": #{m[1]} : #{m[2]}"
    elsif m = line.match((/^(\s*)- (.+)$/))
      return "*" * (m[1].size / 2 + 1) + " #{m[2]}"
    elsif m = line.match((/^\|(.+)\|$/))
      return convert_table(m, line)
    else
      return line
    end
  end

  def check_in(line)
    m = []
    if m = line.match(/\[\[file:(.+)\]\]/)
      return m ? convert_attach(m, line) : line
    elsif m = line.match(/\[\[(.+)\]\[(.+)\]\]/)
      return m ? convert_link(m, line) : line
    else
      return line
    end
  end

  def check_block?(line)
    m = line.match(/^\#\+(.+)$/)
    if m
      @outputs << check_options(m, line)
      return true
    end
    if @in_example == true
      @outputs << line
      return true
    end
    return false
  end

  def check_options(m, line)
    case m[1]
    when "begin_example"
      @in_example = true
      return "<<<"
    when "begin_src ruby"
      @in_example = true
      return "<<< ruby"
    when "end_src", "end_example"
      @in_example = false
      return ">>>"
    else
      return "// " + line
    end
  end

  def convert_attach(m, line)
    line.gsub!(m[0], "\{\{attach_view(#{File.basename(m[1])})\}\}")
  end

  def convert_link(m, line)
    line.gsub!(m[0], "[[#{m[2]}|#{m[1]}]]")
  end

  def convert_table(m, line)
    # should be ...
    line.gsub!("| ", "|| ")[0..-2]
  end
end
