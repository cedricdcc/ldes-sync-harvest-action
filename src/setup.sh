#!/bin/bash

# Echo the branches
echo "Branches are: $BRANCHES"

# check if there is a branch called restricted/ldes in the branches
if [[ $BRANCHES == *"restricted/ldes"* ]]; then
    # this means that the restricted/ldes branch exists
    # so sync must be run 
    python ldes_sync.py
else
    # no restricted/ldes branch exists
    # so download must be run
    bash ldes_download.sh
    python ttl_to_yml.py
    python make_branches.py
fi