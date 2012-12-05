class CompileUtils
  def self.get_sub_directories(folder)
    Dir.glob("source/#{folder}/**/").map { |x| x.gsub("source/", "")[0..-2] }
  end
end
