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
      line = check_link line
      line = check_head line
      @outputs << line
    end
    @outputs.join("\n")
  end

  private

  def check_head(line)
    return line if line == ""
    m = []
    if m = line.match(/^(\*+) (.+)$/) # head
      return "!" * m[1].size + " #{m[2]}"
    elsif m = line.match(/^(\s*)\d\. (.+)$/) # numbered_list
      return "#" * (m[1].size / 3 + 1) + " #{m[2]}"
    elsif m = line.match(/^- (.+) :: (.+)$/) # description
      return ": #{m[1]} : #{m[2]}"
    elsif m = line.match((/^(\s*)- (.+)$/)) # non-numbered_list
      return "*" * (m[1].size / 2 + 1) + " #{m[2]}"
    elsif m = line.match((/^\|(.+)\|$/)) # table
      return convert_table(m, line)
    else
      return line
    end
  end

  def check_link(line)
    m = []
    if m = line.match(/\[\[(.+)\]\]/)
      line2 = recursive_convert_link(line)
    else
      line2 = line
    end
    return line2
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

  def recursive_convert_link(line)
    m0 = line.match(/(\[\[.+?\]\])(.*)/)
    return if m0 == nil
    if m0[2].match(/\W/)
      recursive_convert_link(m0[2]) # for multiple links
    end
    m1 = m0[1].match(/\[\[(.+?)\](.*)\]/)
    return line.gsub!(m1[0], hiki_link(m1))
  end

  def hiki_link(m1)
    string = m1[0]
    string2 = if url?(m1[1]) == nil
        if m = string.match(/\[\[(.+)\]\[(.+)\]\]/)
          "{{attach_anchor_string(#{m[2]},#{m[1]})}}"
        elsif m = string.match(/\[\[(.+)\]\]/)
          "{{attach_anchor(#{m[1]})}}"
        end
      else
        if m = string.match(/file:(.+)\]\]/) # url? judges file:hoge.pdf == url
          "{{attach_anchor(#{m[1]})}}"
        else
          if m2 = m1[2].match(/\[(.+)\]/)
            "[[#{m2[1]}|#{m1[1]}]]"
          else
            "[[#{m1[1]}]]"
          end
        end
      end
    return string2
  end

  require "uri"

  def url?(url_string)
    URI::DEFAULT_PARSER.make_regexp.match(url_string)
  end

  def convert_table(m, line)
    # should be ...
    if line[0..1] == "|-"
      nil
    else
      line.gsub!("| ", "|| ")[0..-2]
    end
  end
end
