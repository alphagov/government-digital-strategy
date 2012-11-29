#!/bin/bash

echo "-> Fetching Assisted Digital"
ruby compiling/get_assisted_digital.rb

echo "-> Running build script"
ruby compiling/build.rb $1 --trace

echo "-> Finished! Run the server and visit http://localhost:8080"
echo "---> the server can be run with the command ruby built-server.rb"
