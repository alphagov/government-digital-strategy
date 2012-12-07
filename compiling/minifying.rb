require_relative "./utils.rb"
require "formatador"
require "paint"

class Minifying
  def self.minify_js
    @f = Formatador.new
    @f.indent { @f.display_line("Running R.js optimizer") }
    %x[cd assets/javascripts && node ../../node_modules/requirejs/bin/r.js -o name=app out=built.js baseUrl=. && cd ../../]
    Dir.glob("built/**/*.html").each do |file|
      content = Utils.read_from_file(file)
      content.gsub!(/<script src="\/assets\/javascripts\/require.js" data-main="\/assets\/javascripts\/app.js"><\/script>/) {
        '<script src="/assets/javascripts/require.js"></script>
         <script src="/assets/javascripts/built.js"></script>'
      }
      Utils.write_to_file(content, file)
    end
  end
  def self.minify_css
    @f = Formatador.new
    Dir.glob("built/assets/css/*.css").each do |file|
      file_name = file.split("/").last
      file_split = file_name.split(".")
      file_split.pop
      file_no_ext = file_split.join "."
      @f.indent {
        @f.display_line("minifying #{file} to assets/css/#{file_no_ext}.min.css")
      }
      %x[./node_modules/clean-css/bin/cleancss -o assets/css/#{file_no_ext}.min.css #{file}]
      Dir.glob("built/**/*.html").each do |html_file|
        content = Utils.read_from_file(html_file)
        file_name = file.split "/"
        file_name = file_name.last.split(".")[0]
        content.gsub!(/\/assets\/css\/#{file_name}.css/) { |match|
          "/assets/css/#{file_name}.min.css"
        }
        Utils.write_to_file(content, html_file)
      end
    end

  end
end
