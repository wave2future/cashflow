#!/bin/sh
locales="de es fr it ja ko zh-Hans zh-Hant"

for i in $locales; do
    echo $i
    if [ -e $i.txt ]; then
	iconv -f UTF-8 -t UTF-16BE $i.txt >  ../$i.lproj/Localizable.strings
    fi
done
