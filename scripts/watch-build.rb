require "listen"
require "formatador"

def run_build
  Formatador.display_line("Running Build script")
  Formatador.display_line(`./local-build.sh`)
  Formatador.display_line("Waiting for next file change")
end

run_build

listener = Listen::MultiListener.new('source', 'assets', :ignore => %r{^css/}) do |modified, added, removed|
  Formatador.display_line("Detected File Change: #{modified.inspect}")
  run_build
end
listener.latency(1)
listener.start

