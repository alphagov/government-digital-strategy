require "pdfkit"
require "fileutils"
require "wicked_pdf"

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
    # code.gsub!(/\/assets\/css\/print\.css/) { |match|
    #   puts "MATCHED: #{match}"
    #   "http://localhost:8080/assets/css/print.css"
    # }
    code.gsub!(/<link href="\/assets\/css\/print\.min\.css" rel="stylesheet" media="print">/) { |match|
      puts "MATCHED: #{match}"
      '<link href="http://localhost:8080/assets/css/print.css" rel="stylesheet" media="screen">'
    }


    # replace the link to the PDF doc with a link to the online one
    code.gsub!(/<a href="(?!http:\/\/)(.*?)\.pdf"(.*?)>(.+?)<\/a>/) { |match|
      puts "MATCHED: #{match}"
      # groups
      # $1 = PDF name
      # $2 = extra attributes
      # $3 = text within link
      "<a href=\"http://publications.cabinetoffice.gov.uk#{self.pdf_names_to_url[$1]}\">an online format</a>"
    }
    File.open("#{folder}/index-pdf.html", "w") { |f| f.write(code) }
    # compile PDF from new file
    name = folder.split("/").last
    `wkhtmltopdf --disable-javascript -B 30mm -L 30mm -R 30mm -T 20mm #{folder}/index-pdf.html #{folder}/#{self.pdf_names[name] || name}.pdf`
    # `rm #{folder}/index-pdf.html`


    # puts self.upload(folder)

  end

  def self.upload(folder)
    file_name = folder.split("/").last
    file_name = self.pdf_names[file_name] || file_name
    save_path = "#{folder}/#{file_name}.pdf"
    puts save_path
    `scp #{save_path} stevena@94.236.18.105:/var/www/strategy/government-digital-strategy-prerelease/#{folder}/#{file_name}.pdf `
    puts "PDF Uploaded to #{save_path}"
    #scp -r assets sgreig@94.236.18.106:/var/www/publications/assets
  end
end

