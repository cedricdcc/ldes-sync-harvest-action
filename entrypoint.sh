#! /bin/sh
pwd

ls -al

echo "repo name is:" GITHUB_REPOSITORY

cd ../..
pwd
ls -al
# copy over ./github/workspace/* /*
rsync --recursive --progress -avzh ./github/workspace/* ./

cd src

npm install -g @treecg/actor-init-ldes-client
npm install -g yaml 
npm list --depth=0

# executing the setup.sh script
bash setup.sh

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

echo "listing all files in the root directory"
ls -al

rsync --recursive --progress -avzh --exclude=.git --exclude=.github --exclude=.dockerenv --exclude=README.md --exclude=bin --exclude=boot --exclude=config.yml --exclude=dev --exclude=entrypoint.sh --exclude=etc --exclude=github --exclude=home --exclude=lib --exclude=lib64 --exclude=media --exclude=mnt --exclude=opt --exclude=proc --exclude=node_modules --exclude=package-lock.json --exclude=package.json --exclude=poetry.lock --exclude=pyproject.toml --exclude=run --exclude=root --exclude=sbin --exclude=src --exclude=srv --exclude=sys --exclude=tmp --exclude=usr --exclude=var ./ ./github/workspace