require_relative "./utils.rb"

class Minifying
  def self.minify_js
    puts "-> Running R.js optimizer"
    %x[cd assets/javascripts && node ../../r.js -o name=app out=built.js baseUrl=. && cd ../../]
    puts "-> Replacing JS links in all files"
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
    puts "-> Running cleanCSS"
    Dir.glob("built/assets/css/*.css").each do |file|
      # ./node_modules/clean-css/bin/cleancss -o min.css assets/css/style.css
      file_name = file.split("/").last
      file_split = file_name.split(".")
      file_split.pop
      file_no_ext = file_split.join "."
      puts "--> minifying #{file} to assets/css/#{file_no_ext}.min.css"
      %x[./node_modules/clean-css/bin/cleancss -o assets/css/#{file_no_ext}.min.css #{file}]
      puts "--> updating stylesheet links"
      Dir.glob("built/**/*.html").each do |html_file|
        content = Utils.read_from_file(html_file)
        # content.gsub!(/<link href="(.+)\/(.+?)\.css" (.+)>/) { |match|
        #   puts "Matched Link: #{match} in file #{file}"
        #   "<link href='#{$1}/#{$2}.min.css' #{$3}>"
        # }
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
