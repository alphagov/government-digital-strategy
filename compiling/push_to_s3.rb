require "aws-sdk"

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
  obj = bucket.objects[file_path]
  obj.write(Pathname.new(file))
end

