class CompileUtils
  def self.get_sub_directories(folder)
    Dir.glob("source/#{folder}/**/").map { |x| x.gsub("source/", "")[0..-2] }
  end

  # list all the top level folders in source
  def self.top_level_folders
    Dir.glob("source/*/").select {
      |x| x != "source/partials/"
    }.map {
      # the [0..-2] removes the last char
      # which in this case is the / at the end of the path
      |x| x.gsub("source/", "")[0..-2]
    }
  end

end
