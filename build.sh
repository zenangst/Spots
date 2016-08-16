#!/bin/bash

generate() {
  echo "Generating..."

  jazzy \
    --author 'Hyper Interaktiv AS' \
    --author_url 'http://www.hyper.no' \
    --github_url 'https://github.com/hyperoslo/Spots' \
    --module 'Spots' \
    --readme 'Spots/README.md' \
    --source-directory 'Spots/' \
    --exclude "$2" \
    --swift-version 2.2 -o ./ \
    --xcodebuild-arguments "-scheme,$3" \
    --theme fullwidth \
    --output "$1" \

  echo "Documentation for $1 was generated..."
}

git submodule update --remote
generate ios Mac Spots-iOS
generate 'mac' 'iOS' 'Spots-Mac'
