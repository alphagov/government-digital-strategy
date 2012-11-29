#!/bin/bash
echo "Running local build script"
./local-build.sh deploy

# echo "Compiling PDFs"
# ./pdf.sh built/digital/strategy
# ./pdf.sh built/digital/efficiency
# ./pdf.sh built/digital/research
# ./pdf.sh built/la-ida-review


echo "Moving files into deploy folder"
ruby compiling/deploy.rb

if [ "$1" = "upload" ]
then
  echo "Uploading to S3"
  ruby compiling/push_to_s3.rb
fi

echo "DONE"
echo "Run ruby deploy-server.rb to view the results on Port 9090"


