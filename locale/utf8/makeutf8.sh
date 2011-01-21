#!/bin/sh
locales="de es fr it ja ko zh-Hans zh-Hant"

for i in $locales; do
    echo $i
    iconv -f utf-16 -t utf-8 ../$i.lproj/Localizable.strings > $i.txt
done
