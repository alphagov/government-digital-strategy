# encoding: utf-8

require_relative "./compileutils.rb"
require "formatador"

class ProcessContents

  # pre-process the Markdown before compilation to deal with our extra stuff
  def self.process(contents, folder = "")
    @f = Formatador.new
    contents.force_encoding("UTF-8")

    # sort out partials first so everything else can use them fine
    contents.gsub!(/{include\s*(.+)\.(.+)}/) { |match|
      @f.indent {
        @f.display_line("Replacing partial #{match}")
      }
      CompileUtils.get_partial_content $1, $2
    }

    # more regex replacing for the department responses
    # need to check and we don't want to do this stuff usually
    if contents.include?("{{DEPARTMENTRESPONSE}}")
       action_number = "00"

       contents.gsub!("{{DEPARTMENTRESPONSE}}", "")
       # main action headings
       contents.gsub!(/#Action ([0-9]{2}):\s(.+)/) {
         # group $1 = action number
         action_number = $1
         # group $2 = action description
         resp = "<div class='action-header'><div class='content-wrapper'><div class='title'>"
         resp += "<h1><span>Action</span> #{action_number}</h1>"
         resp += "<p>#{$2}</p></div></div></div>"
         resp
       }

       # department response heading
       contents.gsub!(/##What the departments are doing/) { |match|
         # section div is closed off later
        "<div class='section'>\n\n#{match}"
       }

       # each deparment response
       contents.gsub!(/{department}/) {
         "<div class='department'>"
       }

       # each department response heading
       contents.gsub!(/##(.+)/) {
         "<h2><span class='organisation-logo'><span>#{$1}</span></span></h2>"
       }

       # each department response text
       contents.gsub!("{statement}", "<div class='statement'>")
       contents.gsub!("{/statement}", "</div>")

       # closing div for each deparment
       contents.gsub!("{/department}", "</div>")

       # navigation links
       contents.gsub!(/{navigation}/) {
         resp = "<div class='section'><div class='action-footer'>"
         # next link
         resp += "<div class='next-link'>"
         unless action_number == "14"
           next_number = action_number.to_i + 1
           next_number = (next_number < 10) ? "0#{next_number}" : next_number.to_s
           resp += "<a href='../#{next_number}' title='Next action'><span>Action #{next_number}</span><span class='arrow-next'></span></a>\n"
         end
         resp += "</div>"
         resp += "<div class='prev-link'>"
         unless action_number == "01"
           next_number = action_number.to_i - 1
           next_number = (next_number < 10) ? "0#{next_number}" : next_number.to_s
           resp += "<a href='../#{next_number}' title='Prev action'>"
           resp += "<span class='arrow-prev'></span><span>Action #{next_number}</span></a>\n"
         end
         resp += "</div>\n"

         resp += "</div></div>"

       }
    end

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
    contents.gsub!(/[…]/, "...")
    contents.gsub!(/[–]/, "--")

    # lets us do ^5^ => <sup>5</sup>
    contents.gsub!(/\^(.+)\^/) { "<sup>#{$1}</sup>" }
    # this is some weird non-breaking-space unicode that was causing us problems with random chars appearing.
    contents.gsub!(/\u00a0/, " ")
    contents.gsub!(/{page-break}/, "<div class='page-break'></div>")
    contents.gsub!(/{collapsed}/, "<div class='theme'>")
    contents.gsub!(/{\/collapsed}/, "</div>")
    contents.gsub!(/{TIMESTAMP}/) {
      date = Shell.execute("git log -1 --pretty=format:'%ad%x09' source/#{folder}").stdout
      # if we dont get a date, just go for the current time.
      date = (date == "" ? Time.now : DateTime.parse(date))
      "[#{date.stamp("1 Nov 2012 at 12:30 am")}](https://github.com/alphagov/government-digital-strategy/commits/master/source/#{folder})"
    }
    # shortcut for PDF linking
    contents.gsub!(/{PDF=(.+)}/) {
      "[PDF format](#{$1})"
    }
    contents.gsub!(/###theme(.+)/) { |match|
      m = $1
      m.strip!
      "####{m}\n {: .theme-head}"
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
