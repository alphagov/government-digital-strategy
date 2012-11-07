#!/bin/bash
echo "Running local build script"
./local-build.sh deploy

echo "Compiling PDFs"
ruby build-pdf.rb --folder built/digital/strategy
ruby build-pdf.rb --folder built/digital/efficiency
ruby build-pdf.rb --folder built/digital/research
ruby build-pdf.rb --folder built/la-ida-review


echo "Moving files into deploy folder"
ruby compiling/deploy.rb

echo "DONE"
echo "Run ruby deploy-server.rb to view the results on Port 9090"


