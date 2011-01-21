#!/bin/sh
locales="de es fr it ja ko zh-Hans zh-Hant"

for i in $locales; do
    echo $i
    if [ -e $i.txt ]; then
	iconv -f utf-8 -t utf-16 $i.txt >  ../$i.lproj/Localizable.strings
    fi
done
