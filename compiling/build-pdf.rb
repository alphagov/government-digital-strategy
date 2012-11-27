#!/usr/bin/ruby
require 'rubygems'
require 'commander/import'
require_relative "./pdf.rb"
require "shell/executer.rb"



default_command :build
program :name, 'GDS PDF Generator'
program :version, '1.0.0'
program :description, 'Tool for generating PDF documents'
command :build do |c|
  c.syntax = 'ruby build-pdf.rb build [options]'
  c.option '--folder STRING', String, 'Which folder to use'
  c.action do |args, options|
    if options.folder.nil?
      puts "Error: no folder specified"
    else
      CompilePdf.compile(options.folder)
    end
  end
end
