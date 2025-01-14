#! /bin/sh
pwd

ls -al

echo "repo name is:" $GITHUB_REPOSITORY
cd ../..
pwd
ls -al
# copy over ./github/workspace/* /*
rsync --recursive --progress -avzh ./github/workspace/* ./

cd src
ls -al

npm install -g @treecg/actor-init-ldes-client
npm install -g yaml 
npm list --depth=0

# list all branches in the repository
echo "All branches in the repository:"
BRANCHES=$(git branch -a)
echo "$BRANCHES"

# executing the setup.sh script
bash setup.sh

git config --global --add safe.directory /github/workspace
# set user name and email 
git config --global user.name 'GitHub Actions'
git config --global user.email 'actions@github.com'



# copy over everything in ./ back to ./github/workspace
# overwrite everything in ./github/workspace
# do not copy over the .git folder and the .github folder 
# also do not copy over the following files:
# - entrypoint.sh
# - Dockerfile
# - README.md
# - LICENSE
# - .gitignore
# - .dockerignore
# - .env
# package.json
# poetry.lock
# pyproject.toml
# requirements.txt
# everything in src folder and recursively under src folder
# package-lock.json
# actions.yml

cd ..

rsync --recursive --progress -avzhq --exclude=.git --exclude=.github --exclude=.dockerenv --exclude=README.md --exclude=bin --exclude=boot --exclude=config.yml --exclude=dev --exclude=entrypoint.sh --exclude=etc --exclude=github --exclude=home --exclude=lib --exclude=lib64 --exclude=media --exclude=mnt --exclude=opt --exclude=proc --exclude=node_modules --exclude=package-lock.json --exclude=package.json --exclude=poetry.lock --exclude=pyproject.toml --exclude=run --exclude=root --exclude=sbin --exclude=src --exclude=srv --exclude=sys --exclude=tmp --exclude=usr --exclude=var ./ ./github/workspace
cd ./github/workspace

# commit the changes
git add .
git commit -m "Syncing with LDES data"
git push origin main

ls -al
if [[ $BRANCHES == *"restricted/ldes"* ]]; then
    # this means that the restricted/ldes branch exists
    # so sync must be run 
    echo "LDES sync branch exists"
else
    git checkout -b restricted/ldes
    git add .
    git commit -m "Creating restricted/ldes branch"
    git push origin restricted/ldes
    git checkout main
    echo "Making branches"
    python -u ../../src/make_branches.py
fi

