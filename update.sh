#! /bin/bash

git submodule update --recursive --remote --init
mv ./content/post/static/* static
cd ./content/post
git filter-branch --subdirectory-filter posts -f
cd ../../
