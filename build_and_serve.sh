#!/usr/bin/env bash
# Filename: build_and_serve.sh
# Usage: run from the root of your al-folio / Jekyll repo

set -e

# 1. Clean previous build
echo "Cleaning old build…"
rm -rf _site

# 2. Install dependencies if needed
if [ -f Gemfile ]; then
  echo "Installing Ruby / Jekyll dependencies…"
  bundle install
fi

# 3. Build the site
echo "Building site via Jekyll..."
bundle exec jekyll build --trace

BUILD_DIR="_site"
if [ ! -d "$BUILD_DIR" ]; then
  echo "ERROR: build failed — $_site/ not found"
  exit 1
fi

echo "Build succeeded. Serving $_site/ via local HTTP server…"
echo "Press CTRL+C to stop"

# 4. Serve with Python 3 http.server
#    On Python 3, this serves current directory contents over HTTP.
cd "$BUILD_DIR"
python3 -m http.server 8000
