#!/bin/bash

cd ..
cd ./github/workspace
# list all branches in the repository
echo "All branches in the repository:"
git fetch --all
BRANCHES=$(git branch -a)
echo "$BRANCHES"

cd ../..
cd src

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
    git checkout main
    echo "Locating YML files in the repository and parent folder..."
    echo "Comparing 'original' fields between local and parent YML files..."
    for file in $(find ../../ -name "*.yml"); do
        base=$(basename "$file")
        if [ -f "$base" ]; then
            diff_val=$(grep 'original:' "$base")
            parent_val=$(grep 'original:' "$file")
            if [ "$diff_val" != "$parent_val" ]; then
                cp "$file" "$base"
                echo "Updated $base with parent version in branch $branch"
            fi
        fi
    done
    echo "Parsing objects.json for merged files..."
    BATCH=$(grep -o '"branch": "batch-[0-9]\+"' objects.json | sed "s/[^0-9]//g" | sort -n | tail -n 1)
    NEW_BATCH=$((BATCH + 1))
    echo "New batch would be batch-$NEW_BATCH if merged files exist"
    MERGED=$(grep -o '"status": "merged"' objects.json)
    git add .
    git commit -m "Update YML files from parent changes and update objects.json"
    git push origin main
    if [ ! -z "$MERGED" ]; then
        git checkout -b batch-$NEW_BATCH
        git push origin batch-$NEW_BATCH
        git checkout main
    fi

    # now that the main branch is ahead of all the batch-x branches
    # do a sync from main to all the other batch-x branches so they are up to date with the main branch
    #for branch in $(git branch -a | grep "batch-[0-9]\+"); do
    #    git checkout origin $branch
    #    git fetch origin
    #    git merge -X theirs origin/main
    #    git push origin $branch
    #done

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
    echo "Making branches"
    python -u ../../src/make_branches.py
    git checkout -b restricted/ldes
    git add .
    git commit -m "Creating restricted/ldes branch"
    git push origin restricted/ldes
    git checkout main
fi