#!/bin/bash
echo "-> Running bundle"
bundle

# echo "-> Setting up submodules"
# git submodule init && git submodule update

# echo "-> Updating all submodules"
# git submodule foreach git pull origin master

echo "-> Running build script"
ruby build.rb $1

# echo "-> Commiting changes to the Git submodules"
# eventually, when all our source/folder are submodules, this line will change to
# git add source && git commit ...
# git add source/sample-document && git commit -m "doing a build, updating sub modules"

echo "-> Finished! Run the server and visit http://localhost:8080"
echo "---> the server can be run with the command ruby server.rb"
