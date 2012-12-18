require_relative "./utils.rb"
require "formatador"
require "paint"
require "cssminify"

class Minifying
  # this is a little weird, in that the Ruby class uses the R.js Node optimiser
  # we use the RequireJS optimiser because it can do an awesome job based on
  # our usage of it and how we define dependencies
  def self.minify_js
    @f = Formatador.new
    @f.indent {
      @f.display_line("Running R.js optimizer")
    }
    %x[cd assets/javascripts && node ../../node_modules/requirejs/bin/r.js -o name=app out=built.js baseUrl=. && cd ../../]

    # go through each HTMl file and replace the links to the new minified JS source
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
      # get the file name without the extension
      file_split = file_name.split(".")
      file_split.pop
      file_no_ext = file_split.join "."
      compressed_css = CSSminify.compress(File.read file)
      Utils.write_to_file(compressed_css, "assets/css/#{file_no_ext}.min.css")

      # go through the HTML and update the links to CSS to point to the minified versions
      Dir.glob("built/**/*.html").each do |html_file|
        content = Utils.read_from_file(html_file)
        # get the file name without the extension
        file_name = file.split "/"
        file_name = file_name.last.split(".")[0]
        content.gsub!(/\/assets\/css\/#{file_name}.css/) { |match|
          "/assets/css/#{file_name}.min.css"
        }
        Utils.write_to_file(content, html_file)
      end
    end
    @f.indent {
      @f.display_line("All CSS files fully minified")
    }

  end
end
