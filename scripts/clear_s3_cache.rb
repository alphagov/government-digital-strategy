require "aws-sdk"
require 'openssl'
require 'digest/sha1'
require 'net/https'
require 'base64'
require 'open-uri'
# taken from: http://blog.confabulus.com/2011/05/13/cloudfront-invalidation-from-ruby/
class CloudfrontInvalidator
  def initialize(aws_account, aws_secret, distribution)
    @aws_account = aws_account
    @aws_secret = aws_secret
    @distribution = distribution
  end

  def invalidate(paths)
    date = Time.now.strftime("%a, %d %b %Y %H:%M:%S %Z")
    digest = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), @aws_secret, date)).strip
    uri = URI.parse("https://cloudfront.amazonaws.com/2012-07-01/distribution/#{@distribution}/invalidation")

    req = Net::HTTP::Post.new(uri.path)
    req.initialize_http_header({
      'x-amz-date' => date,
      'Content-Type' => 'text/xml',
      'Authorization' => "AWS %s:%s" % [@aws_account, digest]
    })
    paths.unshift "/digital/"
    paths.unshift "/la-ida-review/"
    paths.unshift "/digital/strategy/"
    paths.unshift "/digital/research/"
    paths.unshift "/digital/efficiency/"
    paths.unshift "/digital/assisted/"
    paths.map! { |path|
      "<Path>#{URI::encode("/#{path}")}</Path>"
    }
    req.body = "<?xml version='1.0' encoding='UTF-8'?><InvalidationBatch xmlns='http://cloudfront.amazonaws.com/doc/2012-07-01/'><Paths><Quantity>#{paths.length}</Quantity><Items>#{ paths.join("\n") }</Items></Paths><CallerReference>INVALIDATE_#{Time.now.utc.to_i}</CallerReference></InvalidationBatch>"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = http.request(req)
    puts res
    # it was successful if response code was a 201
    return res.code == '201'
  end
end
files = Dir.glob("deploy/**/*").select { |file| file.include?(".") }.map { |file|
  file.gsub("deploy/", "")
}

config_raw = File.read("config/s3.config.yml")
config = YAML.load(config_raw)

puts "-> Running Cloudfront Invalidator"
puts "-> Invalidation Successful? #{CloudfrontInvalidator.new(config["access_key"], config["secret_key"], config["distribution"]).invalidate(files)}"
