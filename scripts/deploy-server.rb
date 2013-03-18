require 'webrick'

include WEBrick    # let's import the namespace so
                   # I don't have to keep typing
                   # WEBrick:: in this documentation.

def start_webrick(config = {})
  config.update(:Port => 9090)
  server = HTTPServer.new(config)
  yield server if block_given?
  ['INT', 'TERM'].each {|signal|
    trap(signal) {server.shutdown}
  }
  server.start

end

puts "Site now running on http://localhost:9090"
start_webrick(:DocumentRoot => 'deploy')

