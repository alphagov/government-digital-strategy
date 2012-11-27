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

    # `wkhtmltopdf --disable-javascript -B 30mm -L 30mm -R 30mm -T 20mm #{folder}/index-pdf.html #{folder}/#{self.pdf_names[name] || name}.pdf`
    # `rm #{folder}/index-pdf.html`

  end
end

