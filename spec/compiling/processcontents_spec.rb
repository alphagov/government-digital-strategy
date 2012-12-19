require "rspec"
require_relative "../../compiling/processcontents"
require_relative "../../compiling/compileutils"

# mock compileutils partials method

class CompileUtils
  def self.get_partial_content(x, y)
  end
end

describe ProcessContents do
  describe "matching partials" do
    it "matches a partial include and calls get_partial_content" do
      CompileUtils.should_receive(:get_partial_content).with("test", "md")
      content = "\n {include test.md} \n"
      ProcessContents.process(content, false, true)
    end
  end

  describe "matching annex headings" do
    it "should match Annex with a number" do
      content = "##Annex 01 - Introduction"
      result = ProcessContents.process(content, false, true)
      expected = "{::options auto_ids='false' /}\n\n##<span class='title-index'>Annex 01</span> <span class='title-text'>Introduction</span>\n{: .section-title #introduction}\n{::options auto_ids='true' /}"
      result.should eq expected
    end

  end

end
