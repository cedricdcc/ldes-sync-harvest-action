#! /bin/sh
pwd

ls -al

echo "config is" $1

echo "repo name is:" GITHUB_REPOSITORY

# copy over ./github/workspace/* /*
rsync --recursive --progress -avzh ./github/workspace/* ./

cd src
