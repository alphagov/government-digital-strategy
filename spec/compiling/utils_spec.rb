require "rspec"
require "fileutils"
require "shell/executer.rb"

require_relative "../../compiling/utils.rb"

describe Utils do
  location = "spec/fixtures"
  before(:each) do
    begin
      FileUtils.rm_r "#{location}/test"
    rescue
    end
  end

  describe ".folder_exists?" do
    it "returns true for a folder that does exist" do
      home_dir = File.expand_path("~")
      Utils.folder_exists?(home_dir).should be_true
    end
    it "returns false for a folder that doesn't exist" do
      Utils.folder_exists?("foobarbazdoesntexist").should be_false
    end
  end

  describe ".make_if_not_exists" do
    it "makes a new folder if one doesn't exist" do
      Utils.make_if_not_exists "#{location}/test"
      Shell.execute("ls #{location}/test").success?.should be_true
    end
  end

  describe ".contains_markdown_in_root" do
    it "returns true if the folder contains a MD file" do
      Utils.contains_markdown_in_root(location).should be_true
    end
    it "returns false if the folder doesnt contain a MD file" do
      Utils.contains_markdown_in_root("#{location}/no_markdown").should be_false
    end
  end

  describe ".read_from_file" do
    it "should read the content from the file" do
      Utils.read_from_file("#{location}/test.md").gsub("\n", "").should == "# Some Markdown"
    end
  end

  describe ".read_config" do
    it "should read and parse a YAML config file" do
      Utils.read_config("#{location}/test.yml")["foo"].should == "bar"
    end
  end


end
