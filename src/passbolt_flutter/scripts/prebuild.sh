#!/bin/bash

git submodule update --init --remote --recursive

echo "Generate di files"
flutter packages get
flutter packages pub run build_runner build --delete-conflicting-outputs