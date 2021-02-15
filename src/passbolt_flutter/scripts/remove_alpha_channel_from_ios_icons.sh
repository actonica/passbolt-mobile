#!/bin/bash

# 1. generate icon pack https://appiconmaker.co/Home/Index/acb2eb80-dda4-4473-bbb0-3c0c26198b21
# 2. install imagemagick
# 3. cd to icons directory
# 4. remove alpha channel from icons

for i in `ls *.png`; do convert $i -background black -alpha remove -alpha off $i; done