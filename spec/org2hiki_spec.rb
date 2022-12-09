require "spec_helper"
require "org2hiki"

def assert(org, hiki)
  converted = ToHiki.new.convert(org)
  expect(converted).to eq(hiki)
end

def make_block_comment(src, code = "")
  input = <<EOS
hoge.
#+begin_#{src}#{code}
# comment
print("hello")
#+end_src
fuga.
EOS
  expected = "hoge.\n<<<#{code}\n# comment\nprint(\"hello\")\n>>>\nfuga."
  return [input, expected]
end

describe ToHiki do
  it "convert block" do
    [["src", " ruby"],
     ["src", " python"],
     ["example"]].each do |src, code|
      input, expected = make_block_comment(src, code)
      assert(input, expected)
    end
  end

  it "convert strengthen and deleted words " do
    assert("+word+ hoge", "==word== hoge")
    assert("!項目 !word", "'''項目''' '''word'''")
  end

  it "convert CamelLink to [[CamelLink]]" do
    assert("[[CamelLink]]", "[[CamelLink]]")
  end

  it "convert comment" do
    assert("# hoge hage", "// hoge hage")
  end

  it "convert specific_link" do
    assert("[[https://n.com/ode.ipynb][nb]]", "[[nb|https://n.com/ode.ipynb]]")
    assert("[[https://n.com/ode.ipynb]]", "[[https://n.com/ode.ipynb]]")
    assert("[[hoge.pdf][hoge]]", "{{attach_anchor_string(hoge,hoge.pdf)}}")
    assert("[[hoge.pdf]]", "{{attach_anchor(hoge.pdf)}}")
    assert("[[file:hoge.pdf]]", "{{attach_anchor(hoge.pdf)}}")
    assert("[[file:hoge.png]]", "{{attach_view(hoge.png)}}")
  end

  it "convert links on line" do
    assert(" [[https://n.com/ode.ipynb][nb]], [[hoge.pdf]] ",
           " [[nb|https://n.com/ode.ipynb]], {{attach_anchor(hoge.pdf)}} ")
    #    assert("| 15年度  | [[Exam15.pdf][NumRecipe15]],[[Exam15_ans.pdf][NumRecipe15_ans]] | ",
    #           "|| 15年度  || {{attach_anchor_string(NumRecipe15,Exam15.pdf)}},{{attach_anchor_string(NumRecipe15_ans,Exam15_ans.pdf)}}, ||")
  end

  it "convert head lines" do
    assert("* head1", "! head1")
    assert("** head1", "!! head1")
    assert("*** head1", "!!! head1")
  end

  it "convert lists" do
    assert("- list1", "* list1")
    assert("  - list2", "** list2")
    assert("    - list3", "*** list3")
    assert("      - list4", "**** list4")
  end

  it "convert description" do
    assert("- list1 :: hoge", ": list1 : hoge")
  end

  it "convert options to comments" do
    assert("#+hogehoge", "// #+hogehoge")
  end

  it "convert table" do
    org = <<-EOS
| hoge | hage |
|------+------|
| hoge | hage |
EOS
    hiki = <<-EOS
|| hoge || hage 
|| 
|| hoge || hage 
EOS
    assert(org, hiki.chomp)
  end

  it "convert example" do
    org = <<-EOS
#+begin_example
example
#+end_example
EOS
    hiki = <<-EOS
<<<
example
>>>
EOS
    assert(org, hiki.chomp)
  end

  it "convert ruby src" do
    org = <<-EOS
#+begin_src ruby
ruby
#+end_src
EOS
    hiki = <<-EOS
<<< ruby
ruby
>>>
EOS
    assert(org, hiki.chomp)
  end
end
