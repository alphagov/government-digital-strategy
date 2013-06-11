require "aws-sdk"
require 'openssl'
require 'digest/sha1'
require 'net/https'
require 'base64'
require 'open-uri'

config_raw = File.read("config/s3.config.yml")
config = YAML.load(config_raw)
s3 = AWS::S3.new(
  :access_key_id => config["access_key"],
  :secret_access_key => config["secret_key"]
)

bucket = s3.buckets[config["bucket"]]

files = Dir.glob("deploy/**/*").select { |file| file.include?(".") }

files.each do |file|
  file_path = file.gsub("deploy/", "")
  puts "-> Uploading #{file_path}"
  options = {}
  if file.include?("csv")
    puts "--> File is CSV, setting content options"
    options[:content_type] = "text/csv"
    options[:content_disposition] = "attachment"
  end
  if file.include?("css")
    puts "--> File is CSS, setting content_type"
    options[:content_type] = "text/css"
  end
  obj = bucket.objects[file_path]
  obj.write(Pathname.new(file), options)
end

puts "-> Done"


