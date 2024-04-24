#!/bin/bash

# check if there is a ../.././github/ldes folder in the repository, if not create it

if [ ! -d "../ldes" ]; then
    mkdir "../ldes"
    # put a file into the folder so that it is not empty
    touch "../ldes/.gitkeep"
    # run the ldes_download.sh script
    bash ldes_download.sh
    # run the ttl to yml python script
    python ttl_to_yml.py

    # get the current hash of the repository and write it to a file called last_ldes_hash
    cd ../github/workspace
    git rev-parse HEAD > ./.github/last_ldes_hash
    cd ../../src
else
    # run the ldes_sync.py script
    python ldes_sync.py
fi