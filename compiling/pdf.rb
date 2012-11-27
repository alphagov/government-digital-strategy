require "fileutils"
require "wicked_pdf"
require "pdfcrowd"
require "yaml"
require "shell/executer.rb"
# get contents

class CompilePdf
  def self.pdf_names
    {
      "strategy" => "government-digital-strategy",
      "efficiency" => "digital-efficiency-report",
      "research" => "digital-landscape-research"
    }
  end

  def self.pdf_names_to_url
    {
      "government-digital-strategy" => "/digital/strategy",
      "digital-efficiency-report" => "/digital/efficiency",
      "digital-landscape-research" => "/digital/research",
      "la-ida-review" => "/la-ida-review"
    }
  end
  def self.compile(folder)

    self.compile_zip(folder)
    name = folder.split("/").last
    pdf_config_raw = File.read("config/pdf.config.yml")
    pdf_config = YAML.load(pdf_config_raw)

    client = Pdfcrowd::Client.new(pdf_config["user"], pdf_config["key"])
    client.enableImages(true)
    client.enableBackgrounds(true)
    client.usePrintMedia(false)
    client.enableJavaScript(true)
    client.setFooterHtml("<div style='text-align: right; font-size: 13px; '>%p</div>")
    url_path = folder.gsub(/built\//, "")
    # File.open("#{folder}/#{self.pdf_names[name]}.pdf", 'wb') { |f| client.convertFile("#{folder}/index-pdf.html", f) }
    # pdf = client.convertURI("#{pdf_config["url"]}#{url_path}/")
    pdf = client.convertFile("#{folder}/pdf.zip")
    File.open("#{folder}/#{self.pdf_names[name]}.pdf", 'wb') { |f| f.write(pdf) }
    puts "Created #{folder}/#{self.pdf_names[name]}.pdf"
    puts "Remaining tokens: #{client.numTokens()}"

    # remove zip
    Shell.execute("cd #{folder} && rm pdf.zip")

  end

  def self.compile_zip(folder)
    # copy template folder over
    FileUtils.cp_r "assets/pdf-only", "#{folder}/pdf"

    pdf_path = "#{folder}/pdf"


    # merge print + magna-charta CSS into one file
    print_css = IO.read "assets/css/print.css"
    magna_css = IO.read "assets/css/magna-charta.css"
    combined = print_css + "\n\n" + magna_css
    File.open("#{pdf_path}/style.css", 'w') { |f| f.write(combined) }
    index = IO.read "#{folder}/index.html"

    # find all images
    index.gsub!(/<img[^']*?src=\"([^']*?)\"[^']*?>/) { |m|
      puts "Matched image: #{m}"
      image_name = $1.split("/").last
      puts "Imagename: #{image_name}"
      # copy that image into PDF dir
      FileUtils.cp($1[1..-1], "#{pdf_path}/#{image_name}")
      # return just the image name
      "<img src='#{image_name}' />"
    }
    # add new asset paths
    # not removing old ones doesn't matter - it just wont find them
    # add them just before </head>
    index.gsub!(/<\/head>/) {
      new_assets = '<script src="jquery.min.js"></script><script src="magna-charta.min.js"></script><script src="pdf.js"></script><link rel="stylesheet" href="style.css" />'
      "#{new_assets}\n\n</head>"
    }

    # save file
    File.open("#{pdf_path}/index-pdf.html", 'w') { |f| f.write(index) }
    # zip folder up
    Shell.execute("cd #{folder} && zip -vr pdf.zip pdf/")
    # delete folder
    FileUtils.rm_r(pdf_path)
    # done
  end
end

