require "test_helper"

class Org2hikiTest < Minitest::Test
  def test_that_it_has_a_version_number
    puts "bundle exec rake test TESTOPTS=\"--name=test_desc -v\""
    refute_nil ::Org2hiki::VERSION
  end

  def test_title
    p line = "#+TITLE: test"
    p ToHiki.new.convert(line)
  end

  def test_link
    line = "[[hoge_url][hoge]]"
    assert_equal("[[hoge|hoge_url]]",
                 ToHiki.new.convert(line))
  end

  def test_head
    4.times do |i|
      p line = "*" * i + " hoge"
      assert_equal("!" * i + " hoge",
                   ToHiki.new.convert(line))
    end
  end

  def test_list
    puts ""
    [["- hoge", "* hoge"],
     ["  - hoge", "** hoge"],
     ["    - hoge", "*** hoge"],
    ].each do |input, expected|
      p input
      p actual = ToHiki.new.convert(input)
      assert_equal(expected, actual)
    end
  end

  def test_desc
    p ""
    p input = "- title :: hoge"
    p actual = ToHiki.new.convert(input)
    p expected = ": title : hoge"
    assert_equal(expected, actual)
  end

  def test_enumerate
    p ""
    3.times do |i|
      p line = " " * 3 * i + "1. hoge"
      p actual = ToHiki.new.convert(line)
      assert_equal("#" * (i + 1) + " hoge", actual)
    end
    3.times do |i|
      p line = " " * 3 * i + "#{i}. hoge"
      p actual = ToHiki.new.convert(line)
      assert_equal("#" * (i + 1) + " hoge", actual)
    end
  end
end
