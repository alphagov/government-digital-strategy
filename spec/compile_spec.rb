require_relative "../compiling/compile.rb"
require "shell/executer.rb"

describe Compile do
  before(:each) do
    @folder = "testing-data"
  end
  describe ".get_sub_directories" do
    it "returns the right directories" do
      result = Compile.get_sub_directories @folder
      result.include?("testing-data/testing").should eq true
      result.include?("testing-data/sub-folder").should eq true
      result.include?("testing-data/sub-folder/testing").should eq true
    end
  end

  describe ".make_built_directories" do
    before(:each) do
      Shell.execute("rm -r built/testing-data")
    end
    it "should make the directories" do
      Compile.make_built_directories @folder
      Shell.execute("ls built/testing-data").success?.should eq true
      Shell.execute("ls built/testing-data/testing").success?.should eq true
      Shell.execute("ls built/testing-data/sub-folder").success?.should eq true
      Shell.execute("ls built/testing-data/sub-folder/testing").success?.should eq true
    end
  end

  describe ".merge_markdown" do
    before(:each) do
      Shell.execute("rm -r temp/testing-data")
    end
    it "takes a directory and merges all markdown recursively into temp" do
      Compile.merge_markdown 
      Shell.execute("ls temp/testing-data").success?.should eq true
      Shell.execute("cat temp/testing-data/markdown_joined.md").success?.should eq true
      Shell.execute("cat temp/testing-data/sub-folder/markdown_joined.md").success?.should eq true
    end
  end

  describe ".fetch_markdown" do
    it "gets markdown that's in the root folder" do
      md = Compile.fetch_markdown(@folder)
      md.length.should eq 6
      md.include?("00-contents.md").should eq true
    end
  end

  describe ".apply_template_compile" do
    before(:each) do
      Shell.execute("rm -r built/testing-data")
    end
    it "finds the markdown_joined files and compiles them" do
      Compile.apply_template_compile
      Shell.execute("ls built/testing-data").success?.should eq true
      Shell.execute("cat built/testing-data/index.html").success?.should eq true
      Shell.execute("cat built/testing-data/sub-folder/index.html").success?.should eq true
    end
  end

  describe ".find_single_html_files_in_source" do
    it "finds them" do
      files = Compile.find_single_html_files_in_source
      files.include?("testing-data/test01.html").should eq true
      files.include?("testing-data/testing/test02.html").should eq true
    end
  end

  describe ".process_single_html_files" do
    it "symlinks them into build" do
      Compile.process_single_html_files
      Shell.execute("cat built/testing-data/test01.html").success?.should eq true
      Shell.execute("cat built/testing-data/testing/test02.html").success?.should eq true
    end
  end
end
