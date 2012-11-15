# encoding: utf-8
require "kramdown"
require "fileutils"
require "stamp"
require_relative "./utils.rb"
require_relative "./githubfetch.rb"
require "shell/executer.rb"


class Compile
  def self.run
    puts "-> Compiling Sass"
    Compile.compile_sass

    puts "-> Merging Markdown into One"
    Compile.merge_markdown

    puts "-> Dealing with single *.html files in source/"
    Compile.process_single_html_files

    puts "-> Compiling markdown to HTML"
    Compile.apply_template_compile

    puts "-> Done"
  end

  # compiles all sass
  def self.compile_sass
    Dir.foreach("assets/sass") do |file|
      if file.split(".").last == "scss"
        puts "--> Compiling #{file}"
        Sass.compile_file("assets/sass/#{file}", "assets/css/#{file.split(".").first}.css")
      end
    end
  end

  # merge the markdown files into the markdown joined files
  def self.merge_markdown
    tlf = self.top_level_folders
    tlf.each do |t|
      folders = self.get_sub_directories t
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
    self.find_single_html_files_in_source.each do |file|
      parent_dirs = file.split("/")
      parent_dirs.pop
      Shell.execute("mkdir -p built/#{parent_dirs.join('/')}")
      self.process_html_template(file)
      # FileUtils.cp("source/#{file}", "built/#{file}")
    end
  end

  # take all markdown_joined files and move them into html
  def self.apply_template_compile
    template = ""
    self.get_markdown_joined_files.each do |mj|
      if mj.index("digital/") != nil
        File.open("assets/templates/digital_doc_template.html", "r") do |temp|
          template = temp.read
        end
      else
        File.open("assets/templates/generic_template.html", "r") do |temp|
          template = temp.read
        end
      end
      puts "--> Compiling #{mj}"
      self.compile_single_markdown_joined mj, self.process_template_partial( template.clone )
    end
  end

  # takes a single markdown joined file, and the template HTML, and compiles
  def self.compile_single_markdown_joined(path, template)
    parent_path = path.split("/")
    parent_path.pop
    parent_path = parent_path.join("/")
    Shell.execute("mkdir -p built/#{parent_path}")
    File.open("built/#{parent_path}/index.html", "w") do |index|
      template.gsub!(/<!--TIME-->/, Time.now.to_s)
      template.gsub!(/<!--META-->/) {
        File.exists?("source/#{parent_path}/meta.html") ? Utils.read_from_file("source/#{parent_path}/meta.html") : ""
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

  # from here on in, these methods are only called by the methods above
  # they are kept public for tests (TODO: find a better way to do this)

  # lists all the sub directories of a particular folder within source
  def self.get_sub_directories(folder)
    Dir.glob("source/#{folder}/**/").map { |x| x.gsub("source/", "")[0..-2] }
  end

  # sets up the correct folder structure in built/ for the folder within source/
  def self.make_built_directories(folder)
    folders = Compile.get_sub_directories folder
    folders.each do |folder|
      Utils.make_if_not_exists("built/#{folder}")
    end
  end

  # list all the top level folders in source
  def self.top_level_folders
    Dir.glob("source/*/").select { |x| x != "source/partials/" }.map { |x| x.gsub("source/", "")[0..-2] }
  end

  # find all markdown files within the source folder
  def self.fetch_markdown(folder)
    Dir.glob("source/#{folder}/*.md").map { |x| x.split("/").last }
  end


  # find all HTML files with source/
  def self.find_single_html_files_in_source
    Dir.glob("source/**/*.html").select { |x|
      ! ( x.include?("source/partials") || x.include?("meta") )
    }.map { |x| x.gsub("source/", "") }
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
            contents = "<div class='document-title'>\n\n#{self.pre_process contents, folder}\n\n</div>"
          else
            contents = "<div class='section'>\n\n#{self.pre_process contents, folder}\n\n</div>"
          end
          open.puts contents
        end
      end
    end
  end


  # find all the markdown_joined files within temp
  def self.get_markdown_joined_files
    Dir.glob("temp/**/markdown_joined.md").map { |x| x.gsub("temp/", "")}
  end


  def self.get_partial_content(file_path, type)
    path = file_path.split("/")
    if path.length > 1
      file_name = path.pop
      partial_content = Utils.read_from_file("source/partials/#{path.join "/"}/_#{file_name}.#{type}")
    else
      partial_content = Utils.read_from_file("source/partials/_#{path.first}.#{type}")
    end
  end
  # pre-process the Markdown before compilation to deal with our extra stuff
  def self.pre_process(contents, folder = "")
    contents.force_encoding("UTF-8")

    # sort out partials first so everything else can use them fine
    contents.gsub!(/{include\s*(.+)\.(.+)}/) { |match|
      puts "--> Replacing partial #{match}"
      self.get_partial_content $1, $2
    }

    contents.gsub!(/##([0-9]+) (.+)/) { |match|
      number = $1
      title = $2
      slug = $2.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
      "{::options auto_ids='false' /}\n\n##<span class='title-index'>#{number}</span><span class='title-text'>#{title.strip}</span>\n{: .section-title ##{slug}}\n{::options auto_ids='true' /}"
    }

    contents.gsub!(/##Annex ([0-9]) - (.+)/) {
      number = $1
      title = $2
      slug = $2.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
      "{::options auto_ids='false' /}\n\n##<span class='title-index'>Annex #{number}</span><span class='title-text'>#{title}</span>\n{: .section-title ##{slug}}\n{::options auto_ids='true' /}"
    }

    #add links to figures
    contents.gsub!(/^(Figure .+?){: \.fig (#fig-.+?)}$/m) { |match|
      "<a href='#{$2}' class='figure-permalink' title='Right click to copy a link to this figure'>Link to this</a> \n #{match}"
    }
    contents.gsub!(/{pull}/) { "{: .pull}" }
    contents.gsub!(/{big-pull}/) { "{: .big-pull}" }
    contents.gsub!(/{fig}/) { "{: .fig}" }
    contents.gsub!(/([£])/, '&pound;')
    contents.gsub!(/([€])/, '&euro;')
    contents.gsub!(/[”“]/, '"')
    contents.gsub!(/[‘’]/, "'")
    contents.gsub!(/[…]/, "...")
    contents.gsub!(/[–]/, "--")
    contents.gsub!(/\^(.+)\^/) { "<sup>#{$1}</sup>" }
    contents.gsub!(/\u00a0/, " ")
    contents.gsub!(/{collapsed}/, "<div class='theme'>")
    contents.gsub!(/{\/collapsed}/, "</div>")
    contents.gsub!(/{TIMESTAMP}/) {
      date = Time.now
      if folder
        puts folder
        date = Shell.execute("git log -1 source/#{folder}/ | cut -d \" \" -f 1-5").stdout.gsub!("\e[34m","").gsub!("\n","")
        puts "date: #{date}"
        date = DateTime.parse(date)
      end

      if folder
        "[#{date.stamp("1 Nov 2012 at 12:30 am")}](https://github.com/alphagov/government-digital-strategy/commits/master/source/#{folder})"
      else
        "[#{date.stamp("1 Nov 2012 at 12:30 am")}](http://github.com/government-digital-strategy-prerelease)"
      end
    }
    contents.gsub!(/{PDF=(.+)}/) {
      "[PDF format](#{$1})"
    }
    contents.gsub!(/###theme(.+)/) { |match|
      m = $1
      m.strip!
      "####{m}\n {: .theme-head}"
    }

    contents.gsub!(/{(\w+) .(.+)}/) {
      "<#{$1} class='#{$2}'>"
    }
    contents.gsub!(/{\/(\w+)}/) {
      "</#{$1}>"
    }

    #deal with actions
    contents.gsub!(/####Action ([0-9]+): (.+)/) {
      "<h4 id='action-#{$1}' class='section-title'><span class='title-index'><span>Action </span> #{$1}</span><span class='title-text'>#{$2}</span></h4>"
    }

    contents
  end

  # replace HTML templates
  def self.process_html_template(file)
    template = ""
    # file_contents = Utils.read_from_file("source/#{file}")
    parent_path = file.split "/"
    parent_path.pop
    parent_path = parent_path.join "/"

    # deal with partials
    file_contents = self.process_html_partials(file)

    file_contents.gsub!(/{(.+)_template}/) { |match|
      # save variable for use below and replace the template tag
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
      template_contents = self.process_template_partial(template_contents)

      # save to file
      File.open("built/#{file}", "w") do |html_file|
        html_file.puts template_contents
      end
    else
      puts "--> Didn't find a template, so just copying #{file} to built"
      # need to write file_contents to built/#{file}
      File.open("built/#{file}", "w") do |html_file|
        html_file.puts file_contents
      end
    end
  end

  def self.process_html_partials(file)
    puts "--> process partials in #{file}"
    file_contents = Utils.read_from_file("source/#{file}")
    file_contents.gsub!(/{include\s*(.+)\.(.+)}/) { |match|
      puts "--> Found partial #{match} in #{file}"
      # partial_contents = Utils.read_from_file("source/partials/_#{$1}.#{$2}")
      puts "Found template partial: #{match}"
      partial_contents = self.get_partial_content($1, $2)
      if $2 == "md"
        # markdown
        partial_contents = Kramdown::Document.new(self.pre_process(partial_contents)).to_html
      end
      partial_contents
    }
    file_contents
  end

  def self.process_template_partial(template_contents)
    # TODO: this and the above method are not very DRY - abstract into utils?
    file_contents = template_contents
    file_contents.gsub!(/{include\s*(.+)\.(.+)}/) { |match|
      # partial_contents = Utils.read_from_file("source/partials/_#{$1}.#{$2}")
      puts "Found template partial: #{match}"
      partial_contents = self.get_partial_content($1, $2)
      if $2 == "md"
        # markdown
        partial_contents = Kramdown::Document.new(self.pre_process(partial_contents)).to_html
      end
      partial_contents
    }
    file_contents
  end
end
