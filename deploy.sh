#!/bin/bash
echo "Running local build script"
./local-build.sh deploy

echo "Copying stuff over"
ruby compiling/deploy.rb

echo "DONE"
echo "Run ruby deploy-server.rb to view the results on Port 9090"


