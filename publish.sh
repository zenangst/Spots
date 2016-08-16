#!/bin/bash

./build.sh
git add .
git commit -am "Audo generated documentation"
git push
git status
