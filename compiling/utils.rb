require "shell/executer.rb"
require "yaml"

class Utils
  def self.folder_exists?(folder)
    Shell.execute("ls #{folder}").success?
  end

  def self.make_if_not_exists(folder)
    if !self.folder_exists?(folder)
      Shell.execute("mkdir -p #{folder}")
    end
  end

  def self.contains_markdown_in_root(folder)
    Dir.glob("#{folder}/*.md").length > 0
  end

  def self.read_from_file(file)
    IO.read file
  end

  def self.write_to_file(content, file)
    File.open(file, 'w') { |f| f.write(content) }
  end

  def self.read_config(file)
    YAML.load(File.read(file))
  end

end
