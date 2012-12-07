# encoding: utf-8
require "kramdown"
require "fileutils"
require "shell/executer.rb"
require "formatador"
require "paint"
require "stamp"

require_relative "./utils.rb"
require_relative "./compileutils.rb"
require_relative "./compilesass.rb"
require_relative "./xmlfiles.rb"
require_relative "./processcontents.rb"


class Compile
  def self.run
    @f = Formatador.new
    @f.display_line(Paint["Compiling Sass", :blue])
    CompileSass.compile_sass_files("assets/sass")

    @f.display_line(Paint["Merging Markdown into One", :blue])
    Compile.merge_markdown

    @f.display_line(Paint["Dealing with single HTML files in source", :blue])
    Compile.process_single_html_files

    @f.display_line(Paint["Moving caption XML files over", :blue])
    XmlFiles.process_xml_files("source/**/*.xml", "source", "built")

    @f.display_line(Paint["Compiling Markdown to HTML", :blue])
    Compile.apply_template_compile

    @f.display_line(Paint["Done!", :green])

  end

  # merge the markdown files into the markdown joined files
  def self.merge_markdown
    tlf = CompileUtils.top_level_folders
    tlf.each do |t|
      folders = CompileUtils.get_sub_directories t
      folders.each do |folder|
        if Utils.contains_markdown_in_root("source/#{folder}")
          Utils.make_if_not_exists("temp/#{folder}")
          self.create_markdown_joined(folder)
        end
      end
    end
  end

  # process all html files that are floating around in source
  def self.process_single_html_files
    CompileUtils.find_single_html_files_in_source.each do |file|
      parent_dirs = file.split("/")
      parent_dirs.pop
      Shell.execute("mkdir -p built/#{parent_dirs.join('/')}")
      self.process_html_template(file)
    end
  end

  # take all markdown_joined files and move them into html
  def self.apply_template_compile
    template = ""
    CompileUtils.get_markdown_joined_files.each do |mj|
      if mj.index("digital/") != nil
        File.open("assets/templates/digital_doc_template.html", "r") do |temp|
          template = temp.read
        end
      else
        File.open("assets/templates/generic_template.html", "r") do |temp|
          template = temp.read
        end
      end
      @f.indent {
        @f.display_lines("Compiling #{mj}")
      }
      self.compile_single_markdown_joined mj, self.find_compile_partial(template.clone)
    end
  end

  # takes a single markdown joined file, and the template HTML, and compiles
  def self.compile_single_markdown_joined(path, template)
    parent_path = CompileUtils.strip_file_from_path(path)

    Shell.execute("mkdir -p built/#{parent_path}")
    File.open("built/#{parent_path}/index.html", "w") do |index|

      # replace the template content with the HTML - sub out the placeholder text for the actual content

      template.gsub!(/<!--TIME-->/, Time.now.to_s)
      template.gsub!(/<!--META-->/) {
        File.exists?("source/#{parent_path}/meta.html") ? Utils.read_from_file("source/#{parent_path}/meta.html") : "Government Digital Strategy"
      }
      template.gsub!(/<!--REPLACE-->/) {
        data = ""
        File.open("temp/#{path}", "r") do |joined_contents|
          contents = joined_contents.read
          compiled_kramdown = Kramdown::Document.new(contents, {:toc_levels => "1..3", :entity_output => :symbolic, :parse_block_html => true}).to_html
          data = compiled_kramdown
        end
        data
      }
      index.puts template
    end
  end




  # merge markdown files in a folder into one markdown_joined.md file within temp/
  def self.create_markdown_joined(folder)
    items_to_compile = []
    Dir.foreach("source/#{folder}") do |item|
      items_to_compile.push item unless item.split(".").last != "md"
    end
    items_to_compile.sort!
    items_to_compile.each do |item|
      File.open("source/#{folder}/#{item}", "r") do |file|
        File.open("temp/#{folder}/markdown_joined.md", "a") do |open|
          contents = file.read
          if item[0..2] == "00-"
            contents = "<div class='document-title'>\n\n#{ProcessContents.process contents, folder}\n\n</div>"
          else
            contents = "<div class='section'>\n\n#{ProcessContents.process contents, folder}\n\n</div>"
          end
          open.puts contents
        end
      end
    end
  end

  # replace HTML templates wihin a file
  def self.process_html_template(file)
    template = ""

    parent_path = CompileUtils.strip_file_from_path(file)

    # deal with partials
    file_contents = self.process_html_partials(file)

    file_contents.gsub!(/{(.+)_template}/) { |match|
      # save variable for use below and replace the template tag with nothing
      template = $1
      ""
    }
    if template != ""
      template_contents = Utils.read_from_file("assets/templates/#{template}_template.html")
      template_contents.gsub!(/<!--REPLACE-->/, file_contents)
      template_contents.gsub!(/<!--META-->/) {
        File.exists?("source/#{parent_path}/meta.html") ? Utils.read_from_file("source/#{parent_path}/meta.html") : ""
      }
      # deal with any partials that might exist in the template
      template_contents = self.find_compile_partial(template_contents)

      # save to file
      File.open("built/#{file}", "w") do |html_file|
        html_file.puts template_contents
      end
    else
      # need to write file_contents to built/#{file}
      File.open("built/#{file}", "w") do |html_file|
        html_file.puts file_contents
      end
    end
  end

  # takes in a single HTML file, reads its contents and returns the contents with all partials compiled
  def self.process_html_partials(file)
    @f.indent {
      @f.display_line("Processing partials in #{file}")
    }
    file_contents = Utils.read_from_file("source/#{file}")
    self.find_compile_partial(file_contents)
  end

  # takes contents, finds the partials, and compile them and put the content in place
  def self.find_compile_partial(file_contents)
    file_contents.gsub!(/{include\s*(.+)\.(.+)}/) { |match|
      partial_contents = CompileUtils.get_partial_content($1, $2)
      if $2 == "md"
        partial_contents = Kramdown::Document.new(ProcessContents.process(partial_contents)).to_html
      end
      partial_contents
    }
    file_contents
  end
end
