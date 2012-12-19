require_relative "utils"

class CompileUtils
  def self.get_sub_directories(folder)
    Dir.glob("source/#{folder}/**/").map { |x| x.gsub("source/", "")[0..-2] }
  end

  # list all the top level folders in source
  def self.top_level_folders
    # filter out the partials folder
    Dir.glob("source/*/").select { |x|
      x != "source/partials/"
    }.map {
      # the [0..-2] removes the last char
      # which in this case is the / at the end of the path
      |x| x.gsub("source/", "")[0..-2]
    }
  end
  # find all the markdown_joined files within temp
  def self.get_markdown_joined_files
    Dir.glob("temp/**/markdown_joined.md").map { |x| x.gsub("temp/", "")}
  end

  # find all HTML files with source/
  def self.find_single_html_files_in_source
    Dir.glob("source/**/*.html").select { |x|
      # need to ignore those within partials or the meta files
      ! ( x.include?("source/partials") || x.include?("meta") )
    }.map { |x| x.gsub("source/", "") }
  end

  # reads in the contents of a partial
  # deals with partials being in a sub directory or just in the root of source/partials/
  def self.get_partial_content(file_path, type)
    path = file_path.split("/")
    if path.length > 1
      file_name = path.pop
      partial_content = Utils.read_from_file("source/partials/#{path.join "/"}/_#{file_name}.#{type}")
    else
      partial_content = Utils.read_from_file("source/partials/_#{path.first}.#{type}")
    end
  end

  def self.strip_file_from_path(path)
    # split it, remove the last bit, and join it again
    # this gets rid of the file from the path
    # eg turns /foo/bar/baz.html to /foo/bar
    parent_path = path.split("/")
    parent_path.pop
    parent_path.join("/")
  end
end
