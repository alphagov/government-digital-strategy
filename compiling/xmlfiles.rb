require "formatador"
class XmlFiles
  def self.process_xml_files(glob, source, dest)
    Dir.glob(glob).map { |f|
      f.gsub!("#{source}/", "")
    }.each do |file|
      FileUtils.cp("#{source}/#{file}", "#{dest}/#{file}")
    end
  end
end
