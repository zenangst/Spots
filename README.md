# Spots `gh-pages`

## Documentation

[Docs](https://hyperoslo.github.io/Spots) generated with [jazzy](https://github.com/realm/jazzy).
Hosted by [GitHub Pages](https://pages.github.com).

## Setup

````bash
git clone https://github.com/hyperoslo/Spots.git
cd Spots/
git checkout gh-pages
git submodule init
git submodule update
````

## Generate

````bash
./build.sh
````

## Preview

### iOS documentation
````bash
open index.html -a Safari
````

### Mac documentation
````bash
open mac/index.html -a Safari
````

## Publish

````bash
./publish.sh
````
