require "shell/executer.rb"
require "fileutils"
require "paint"
require "formatador"
require "yaml"

pwd = Shell.execute('pwd').stdout.gsub("\n", "")
@f = Formatador.new
@f.display_line(Paint["Fetching local copy of the content repository", :blue])
@f.display_line("Make sure the local content repository is checked out on the branch you expect")

config_raw = File.read("config/offlinebuilds.config.yml")
config = YAML.load(config_raw)
path = File.expand_path(config["location"])


@f.indent {
  @f.display_line("Removing old source folder")
}
Shell.execute("cd #{pwd} && rm -r source")

@f.indent {
  @f.display_line("Copying #{path} to #{pwd}/source")
}
FileUtils.cp_r("#{path}/source", "#{pwd}")


