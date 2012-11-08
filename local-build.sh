#!/bin/bash

echo "-> Running build script"
ruby compiling/build.rb $1

echo "-> Finished! Run the server and visit http://localhost:8080"
echo "---> the server can be run with the command ruby built-server.rb"
