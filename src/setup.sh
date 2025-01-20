#!/bin/bash

# Echo the branches
echo "Branches are: $BRANCHES"

# check if there is a branch called restricted/ldes in the branches
if [[ $BRANCHES == *"restricted/ldes"* ]]; then
    # this means that the restricted/ldes branch exists
    # so sync must be run 
    echo "LDES sync branch exists"
    echo "Downloading LDES data"
    bash ldes_download.sh
    echo "Converting TTL to YML"
    python -u ttl_to_yml.py
    cd .. 
    cd ./github/workspace
    # commit the changes
    git checkout restricted/ldes
    cd ../..
    rsync --recursive --progress -avzhq --exclude=.git --exclude=.github --exclude=.dockerenv --exclude=README.md --exclude=bin --exclude=boot --exclude=config.yml --exclude=dev --exclude=entrypoint.sh --exclude=etc --exclude=github --exclude=home --exclude=lib --exclude=lib64 --exclude=media --exclude=mnt --exclude=opt --exclude=proc --exclude=node_modules --exclude=package-lock.json --exclude=package.json --exclude=poetry.lock --exclude=pyproject.toml --exclude=run --exclude=root --exclude=sbin --exclude=src --exclude=srv --exclude=sys --exclude=tmp --exclude=usr --exclude=var ./ ./github/workspace
    cd ./github/workspace
    git add .
    git commit -m "Syncing with LDES data"
    git push origin restricted/ldes
    
    # Get all the different branches in the repo
    echo "Fetching all branches in the repository"
    git fetch --all
    BRANCHES=$(git branch -r | sed 's/origin\///g' | tr '\n' ' ')
    echo "All branches: $BRANCHES"

    # go over each branch and merge the changes
    for branch in $BRANCHES; do
        echo "Checking out branch: $branch"
        git checkout "$branch"
        git merge restricted/ldes
        git push origin "$branch"
    done

    # Function to echo all branches that contain batch- in the name
    find_batch_branches() {
        echo "$BRANCHES" | tr ' ' '\n' | grep 'batch-' | while read branch; do
            echo "Found batch branch: $branch"
            git checkout "$branch"
            # find_yml_files
            check_duplicate_yml_files
        done
    }

    # Call the function
    find_batch_branches
    
else
    # no restricted/ldes branch exists
    # so download must be run
    echo "Downloading LDES data"
    bash ldes_download.sh
    echo "Converting TTL to YML"
    python -u ttl_to_yml.py
    cd .. 
    rsync --recursive --progress -avzhq --exclude=.git --exclude=.github --exclude=.dockerenv --exclude=README.md --exclude=bin --exclude=boot --exclude=config.yml --exclude=dev --exclude=entrypoint.sh --exclude=etc --exclude=github --exclude=home --exclude=lib --exclude=lib64 --exclude=media --exclude=mnt --exclude=opt --exclude=proc --exclude=node_modules --exclude=package-lock.json --exclude=package.json --exclude=poetry.lock --exclude=pyproject.toml --exclude=run --exclude=root --exclude=sbin --exclude=src --exclude=srv --exclude=sys --exclude=tmp --exclude=usr --exclude=var ./ ./github/workspace
    cd ./github/workspace
    # commit the changes
    git add .
    git commit -m "Syncing with LDES data"
    git push origin main
    git checkout -b restricted/ldes
    git add .
    git commit -m "Creating restricted/ldes branch"
    git push origin restricted/ldes
    git checkout main
    echo "Making branches"
    python -u ../../src/make_branches.py
fi