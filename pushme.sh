#!/bin/bash

git add --all
git commit -m "${1:-Auto-commit}"
git push origin main

