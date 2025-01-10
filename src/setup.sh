#!/bin/bash

# check if there is a ../.././github/ldes folder in the repository, if not create it
ls -al

# List all remote branches in the repository
echo "Listing all remote branches in the repository:"
git branch -r

#if [ ! -d "../ldes" ]; then
#    mkdir "../ldes"
#    # put a file into the folder so that it is not empty
#    touch "../ldes/.gitkeep"
#    # run the ldes_download.sh script
#    bash ldes_download.sh
#    # run the ttl to yml python script
#    python ttl_to_yml.py
#else
#    # run the ldes_sync.py script
#    python ldes_sync.py
#fi