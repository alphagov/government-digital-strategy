require "shell/executer.rb"
require "fileutils"
require "paint"
require "formatador"

pwd = Shell.execute('pwd').stdout.gsub("\n", "")
@f = Formatador.new
@f.display_line(Paint["Fetching the Assisted Digital repository contents", :blue])

@f.indent {
  @f.display_line("Making sure the temporary folders exist")
}
unless Shell.execute('ls /tmp/get_external').success?
  FileUtils.mkdir_p("/tmp/get_external")
end

@f.indent {
  @f.display_line("Cloning the Assisted Digital to /tmp/get_external")
}
Shell.execute('cd /tmp/get_external && git clone git@github.com:alphagov/assisted-digital-prerelease.git')

@f.indent {
  @f.display_line("Removing old Assisted Digital")
}
Shell.execute("cd #{pwd} && rm -r /source/digital/assisted")

@f.indent {
  @f.display_line("Copying /tmp/get_external/assisted-digital-prerelease/source to #{pwd}/source")
}
FileUtils.cp_r("/tmp/get_external/assisted-digital-prerelease/source/digital/assisted", "#{pwd}/source/digital")

@f.indent {
  @f.display_line("Taking assets from assisted-digital")
}

FileUtils.cp_r("/tmp/get_external/assisted-digital-prerelease/assets/images/assisted-digital", "#{pwd}/assets/images")

@f.indent {
  @f.display_line("Tidying up /tmp")
}
Shell.execute("cd /tmp/get_external && rm -r assisted-digital-prerelease")


