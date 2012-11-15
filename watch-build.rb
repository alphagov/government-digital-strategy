require "listen"

def run_build
  puts "Running Build Script"
  puts `./local-build.sh`
  puts "Waiting for the next file change"
end

run_build

listener = Listen::MultiListener.new('source', 'assets', :ignore => %r{^css/}) do |modified, added, removed|
  puts "Detected File Change: #{modified.inspect}"
  run_build
end
listener.latency(1)
listener.start

