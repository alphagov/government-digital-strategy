#!/usr/bin/ruby
require 'rubygems'
require 'commander/import'
require 'sass'
require_relative "./compile.rb"
require_relative "./utils.rb"
require_relative "./minifying.rb"
require "shell/executer.rb"

default_command :build
program :name, 'GDS Build Tool'
program :version, '1.0.0'
program :description, 'A build tool for the Government Digital Strategy release'
command :build do |c|
  c.syntax = 'ruby build.rb build'
  c.action do |args, options|
    run_script
  end

  def run_script

    puts "-> Removing old Files"
    remove_old_files

    puts "-> Making any folders we need"
    make_initial_folders

    puts "-> Lets go!"

    Compile.run
    puts "-> Symlinking assets"
    symlink_assets


    if ARGV.length > 0 && ARGV[0] == "deploy"
      ## passed with argument, so need to do compiliation and minification of JS step
      puts "-> Minifying JS"
      Minifying.minify_js
      puts "-> Minifying CSS"
      Minifying.minify_css
    end
  end

  def make_initial_folders
    dirs = Dir.glob("source/*/")
    dirs.each { |dir|
      unless dir == "source/partials/"
        Utils.make_if_not_exists("built/#{dir.split("/")[1]}")
      end
    }
    Utils.make_if_not_exists("assets/css")
    Utils.make_if_not_exists("temp")
  end

  def symlink_assets
    unless Utils.folder_exists?("built/assets")
      puts "-> Creating new symlink"
      Shell.execute("ln -s ../assets/ built/assets")
    else
      puts "-> Symlink already exists"
    end
  end

  def remove_old_files
    Shell.execute("rm -r built/*")
    Shell.execute("rm -r temp/*")
    Shell.execute("rm -r assets/css/*")
  end
end
