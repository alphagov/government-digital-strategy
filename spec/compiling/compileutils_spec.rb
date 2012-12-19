require "rspec"
require_relative "../../compiling/compileutils.rb"

describe CompileUtils do
  describe ".top_level_folders" do
    it "lists the top level folders" do
      tlf = CompileUtils.top_level_folders
      tlf.should include "digital"
      tlf.should_not include "partials"
      tlf.should include "la-ida-review"
    end
  end

  describe ".find_single_html_files_in_source" do
    files = CompileUtils.find_single_html_files_in_source
    it "lists all the single HTML files within source" do
      files.should include "digital/index.html"
      files.should include "digital/strategy/foreword/index.html"
    end
    it "doesn't list any meta.html files or any within partials" do
      files.each do |file|
        file.should_not include "meta"
        file.should_not include "partials"
      end
    end
  end

  describe ".strip_file_from_path" do
    it "removes the file from the path" do
      CompileUtils.strip_file_from_path("/foo/bar.html").should == "/foo"
      CompileUtils.strip_file_from_path("/foo/bar/baz.md").should == "/foo/bar"
    end
  end
end
