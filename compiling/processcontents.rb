# encoding: utf-8

require_relative "./compileutils.rb"
require "formatador"

class ProcessContents

  # pre-process the Markdown before compilation to deal with our extra stuff
  def self.process(contents, folder=false)
    @f = Formatador.new
    contents.force_encoding("UTF-8")

    # sort out partials first so everything else can use them fine
    contents.gsub!(/{include\s*(.+)\.(.+)}/) { |match|
      @f.indent {
        @f.display_line("Replacing partial #{match}")
      }
      CompileUtils.get_partial_content $1, $2
    }

    # match section title headlines
    # these are either Annex ones in the form ##Annex 1 - Foo Bar
    # or section titiles in the form: ##09 Foo Bar
    # this regex matches both
    contents.gsub!(/##(?:Annex\s)?([0-9]+) (?:-)?(.+)/) { |match|
      number = $1
      if match.include? "Annex"
        number = "Annex #{number}"
      end
      title = $2
      slug = $2.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
      "{::options auto_ids='false' /}\n\n##<span class='title-index'>#{number}</span> <span class='title-text'>#{title.strip}</span>\n{: .section-title ##{slug}}\n{::options auto_ids='true' /}"
    }

    #add links to figures
    contents.gsub!(/^(Figure .+?){: \.fig (#fig-.+?)}$/m) { |match|
      "<a href='#{$2}' class='figure-permalink' title='Right click to copy a link to this figure'>Link to this</a> \n #{match}"
    }

    # some shortcuts to adding Kramdown classes
    contents.gsub!(/{pull}/) { "{: .pull}" }
    contents.gsub!(/{big-pull}/) { "{: .big-pull}" }
    contents.gsub!(/{fig}/) { "{: .fig}" }

    # lets escape some unicode characters
    contents.gsub!(/([£])/, '&pound;')
    contents.gsub!(/([€])/, '&euro;')
    contents.gsub!(/[”“]/, '"')
    contents.gsub!(/[‘’]/, "'")
    contents.gsub!(/[…]/, "&ellipsis;")
    contents.gsub!(/[–]/, "--")

    # lets us do ^5^ => <sup>5</sup>
    contents.gsub!(/\^(.+)\^/) { "<sup>#{$1}</sup>" }

    # this is some weird non-breaking-space unicode that was causing us problems with random chars appearing.
    contents.gsub!(/\u00a0/, " ")

    # some more custom syntax for formatting things
    contents.gsub!(/{page-break}/, "<div class='page-break'></div>")
    contents.gsub!(/{collapsed}/, "<div class='theme'>")
    contents.gsub!(/{\/collapsed}/, "</div>")

    on_server = Shell.execute('cat ~/.ssh/config').success?
    # add last edited date to top of each document, taken from Git logs
    if folder && !on_server
      config = Utils.read_config("config/offlinebuilds.config.yml")
      location = File.expand_path(config["location"])
      pwd = Shell.execute('pwd').stdout.gsub("\n", "")
      contents.gsub!(/{TIMESTAMP}/) {
        date = Shell.execute("cd #{location} && git log -1 --pretty=format:'%ad%x09' source/#{folder}").stdout
        Shell.execute("cd #{pwd}")
        # if we dont get a date, just go for the current time.
        date = (date == "" ? Time.now : DateTime.parse(date))
        "[#{date.stamp("1 Nov 2012 at 12:30 am")}](https://github.com/alphagov/government-digital-strategy-content/commits/master/source/#{folder})"
      }
    end

    # shortcut for PDF linking
    # turns {PDF=x.pdf} into [PDF format](x.pdf)
    contents.gsub!(/{PDF=(.+)}/) {
      "[PDF format](#{$1})"
    }


    # shortcut that allows for HTML element inputs
    # eg {div .foo} => <div class="foo">
    contents.gsub!(/{(\w+) .(.+)}/) {
      "<#{$1} class='#{$2}'>"
    }

    # closing tags
    # {/div} => </div>
    contents.gsub!(/{\/(\w+)}/) {
      "</#{$1}>"
    }

    #deal with action headings
    contents.gsub!(/####Action ([0-9]+): (.+)/) {
      "<h4 id='action-#{$1}' class='section-title'><span class='title-index'><span>Action </span> #{$1}</span><span class='title-text'>#{$2}</span></h4>"
    }

    contents
  end

end
