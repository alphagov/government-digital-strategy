require "sass"
require "formatador"
require "paint"

class CompileSass
  def self.compile_sass_files(path)
    @f = Formatador.new
    Dir.foreach(path) do |file|
      if file.split(".").last == "scss"
        @f.indent {
          @f.display_line("Compiling #{file}")
        }
        Sass.compile_file("assets/sass/#{file}", "assets/css/#{file.split(".").first}.css")
      end
    end
  end

end
