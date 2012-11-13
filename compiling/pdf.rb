require "fileutils"
require "wicked_pdf"
require "pdfcrowd"
require "yaml"
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

    # take the index.html
    # make a copy
    # replace any URLs to assets with absolute URLs (eg chuck localhost in front of it)
    code = IO.read("#{folder}/index.html")
    code.gsub!(/\/assets\/images/) { |match|
      puts "MATCHED: #{match}"
      "http://localhost:8080/assets/images"
    }

    # find the link to the print CSS and make it the screen sheet so the PDF generator uses it properly
    # code.gsub!(/<link href="\/assets\/css\/print(\.min)?\.css" rel="stylesheet" media="print">/) { |match|
      # puts "MATCHED: #{match}"
      # '<link href="http://localhost:8080/assets/css/print.css" rel="stylesheet" media="screen">'
    # }


    # replace the link to the PDF doc with a link to the online one
    code.gsub!(/<a href="(?!http:\/\/)(.*?)\.pdf"(.*?)>(.+?)<\/a>/) { |match|
      puts "MATCHED: #{match}"
      # groups
      # $1 = PDF name
      # $2 = extra attributes
      # $3 = text within link
      "<a href=\"http://publications.cabinetoffice.gov.uk#{self.pdf_names_to_url[$1]}\">an online format</a>"
    }
    name = folder.split("/").last
    File.open("#{folder}/index-pdf.html", "w") { |f| f.write(code) }
    pdf_config_raw = File.read("config/pdf.config.yml")
    pdf_config = YAML.load(pdf_config_raw)
    puts pdf_config

    client = Pdfcrowd::Client.new(pdf_config["user"], pdf_config["key"])
    client.enableImages(true)
    client.enableBackgrounds(true)
    client.usePrintMedia(true)
    client.enableJavaScript(false)
    url_path = folder.gsub(/built\//, "")
    # File.open("#{folder}/#{self.pdf_names[name]}.pdf", 'wb') { |f| client.convertFile("#{folder}/index-pdf.html", f) }
    pdf = client.convertURI("#{pdf_config["url"]}/#{url_path}/")
    File.open("#{folder}/#{self.pdf_names[name]}.pdf", 'wb') { |f| f.write(pdf) }
    puts "Remaining tokens: #{client.numTokens()}"

    # `wkhtmltopdf --disable-javascript -B 30mm -L 30mm -R 30mm -T 20mm #{folder}/index-pdf.html #{folder}/#{self.pdf_names[name] || name}.pdf`
    # `rm #{folder}/index-pdf.html`

  end
end

