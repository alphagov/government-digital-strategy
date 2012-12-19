require "rspec"

require_relative "../../compiling/processcontents"
require_relative "../../compiling/compileutils"

# mock compileutils partials method
class CompileUtils
  def self.get_partial_content(x, y)
  end
end

# I'm lazy
def call_process(content)
  ProcessContents.process(content, false, true)
end

describe ProcessContents do
  describe "matching partials" do
    it "matches a partial include and calls get_partial_content" do
      CompileUtils.should_receive(:get_partial_content).with("test", "md")
      content = "\n {include test.md} \n"
      call_process(content)
    end
  end

  describe "matching annex headings" do
    it "should match Annex with a number" do
      content = "##Annex 01 - Introduction"
      result = call_process(content)
      expected = "{::options auto_ids='false' /}\n\n##<span class='title-index'>Annex 01</span> <span class='title-text'>Introduction</span>\n{: .section-title #introduction}\n{::options auto_ids='true' /}"
      result.should eq expected
    end
  end

  describe "figure links" do
    it "should match figure links" do
      content = "Figure 1{: .fig #fig-1}\n"
      result = call_process(content)
      expected = "<a href='#fig-1' class='figure-permalink' title='Right click to copy a link to this figure'>Link to this</a> \n Figure 1{: .fig #fig-1}\n"
      result.should eq expected
    end
  end

  describe "extra custom syntax" do
    it "should replace our custom syntax with expected output" do
      {
        "{pull}" => "{: .pull}",
        "{big-pull}" => "{: .big-pull}",
        "{fig}" => "{: .fig}",
        "{page-break}" => "<div class='page-break'></div>",
        "{collapsed}" => "<div class='theme'>",
        "{/collapsed}" => "</div>",
        "{PDF=foo.pdf}" => "[PDF format](foo.pdf)"
      } .each do |content, expected|
        # have to do .dup as ruby freezes the strings within a hash
        result = call_process(content.dup)
        result.should eq expected
      end
    end
  end

  describe "test the sup replacing" do
    it "replaces ^5^ with a <sup> element" do
      call_process("^5^").should eq "<sup>5</sup>"
    end
  end

  describe "shortcut for adding HTML elements" do
    it "makes the element and adds the class" do
      call_process("{div .foo}").should == "<div class='foo'>"
    end
    it "closes the elements" do
      call_process("{/div}").should == "</div>"
    end
  end

  describe "action headings" do
    it "matches action headings" do
      content = "####Action 01: Introduction"
      expected = "<h4 id='action-01' class='section-title'><span class='title-index'><span>Action </span> 01</span><span class='title-text'>Introduction</span></h4>"
      call_process(content).should == expected

    end
  end




end