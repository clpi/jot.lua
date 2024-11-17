#!/usr/bin/env bash

set -e
git pull

TAG=$(just version)

export TAG

read -r -p "Releasing $TAG -- continue? (Y/n) " pr

if [[ $pr == "n" || $pr == "N" || $pr == "no" || $pr == "No" ]]; then
  echo "OK! Cancelled."
  exit 1
else
  python ./logchg.py
  git add -A
  git commit -m "chore(release): bump version to $TAG for release" || true
  git push
  echo "Creating new git tag $TAG"
  git tag "$TAG" -m "$TAG"
  git push --tags
fi
