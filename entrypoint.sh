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

rsync --recursive --progress -avzh --exclude='.git' --exclude='.github' --exclude='entrypoint.sh' --exclude='Dockerfile' --exclude='README.md' --exclude='LICENSE' --exclude='.gitignore' --exclude='.dockerignore' --exclude='.env' --exclude='package.json' --exclude='poetry.lock' --exclude='pyproject.toml' --exclude='requirements.txt' --exclude='src' --exclude='package-lock.json' --exclude='action.yml' ./ ./github/workspace/