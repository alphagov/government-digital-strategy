require "shell/executer.rb"
require "fileutils"

pwd = Shell.execute('pwd').stdout.gsub("\n", "")

puts "-> Making sure the folders we need exist"
unless Shell.execute('ls /tmp/get_external').success?
  FileUtils.mkdir_p("/tmp/get_external")
end

puts "-> Cloning the Assisted Digital Prerelease to /tmp/get_external"
Shell.execute('cd /tmp/get_external && git clone git@github.com:alphagov/assisted-digital-prerelease.git')

puts "-> Removing old assisted-digital-prelease folder"
Shell.execute("cd #{pwd} && rm -r /source/digital/assisted")

puts "-> Copying /tmp/get_external/assisted-digital-prelease/source to #{pwd}/source/"
FileUtils.cp_r("/tmp/get_external/assisted-digital-prerelease/source/digital/assisted", "#{pwd}/source/digital")

puts "-> Clearing out /tmp"
Shell.execute("cd /tmp/get_external && rm -r assisted-digital-prerelease")


