require "shell/executer.rb"
require "fileutils"
require "paint"
require "formatador"

pwd = Shell.execute('pwd').stdout.gsub("\n", "")
@f = Formatador.new
@f.display_line(Paint["Fetching the source", :blue])

@f.indent {
  @f.display_line("Making sure the temporary folders exist")
}

unless Shell.execute('ls /tmp/get_external').success?
  FileUtils.mkdir_p("/tmp/get_external")
end

@f.indent {
  @f.display_line("Cloning to /tmp/get_external")
}

on_server = Shell.execute('cat ~/.ssh/config').success?
if on_server
  # on a server, so use the deploy key
  Shell.execute('cd /tmp/get_external && git clone git@github-gds-content:alphagov/government-digital-strategy-content.git')
else
  Shell.execute('cd /tmp/get_external && git clone git@github.com:alphagov/government-digital-strategy-content.git')
end

# on the server we always want to use the add-departmental-strategies branch
unless on_server
  # get current branch
  b = `git branch`.split("\n").delete_if { |i| i.strip.chars.first != "*" }
  branch = b.first.gsub("* ","")

  @f.indent {
    @f.display_line("Using branch #{branch}")
  }
  Shell.execute("cd /tmp/get_external/government-digital-strategy-content && git pull origin && git checkout #{branch}")
end



@f.indent {
  @f.display_line("Removing old source folder")
}
Shell.execute("cd #{pwd} && rm -r source")

@f.indent {
  @f.display_line("Copying /tmp/get_external/government-digital-strategy-content/source to #{pwd}/source")
}
FileUtils.cp_r("/tmp/get_external/government-digital-strategy-content/source", "#{pwd}")

@f.indent {
  @f.display_line("Tidying up /tmp")
}
Shell.execute("cd /tmp/get_external && rm -r government-digital-strategy-content")


