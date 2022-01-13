#! /bin/bash

git submodule update --recursive --remote --init
cd ./content/post
git filter-branch --subdirectory-filter posts -f
cd ../../static
git filter-branch --subdirectory-filter static -f
cd ..
