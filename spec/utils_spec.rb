require_relative "../compiling/utils.rb"

describe Utils do
  describe ".contains_markdown_in_root" do
    it "returns true for folders with markdown" do
      Utils.contains_markdown_in_root("source/testing-data").should eq true
      Utils.contains_markdown_in_root("source/testing-data/sub-folder").should eq true
    end
    it "returns false for folders without markdown" do
      Utils.contains_markdown_in_root("source/testing-data/images").should eq false
    end
  end

  describe ".read_markdown_from_file" do
    it "reads in markdown from a file to a string" do
      Utils.read_markdown_from_file("source/testing-data/partials/_hello.md").should eq "this is a partial"
    end
  end
end
