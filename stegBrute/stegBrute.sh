#!/bin/bash

read -p "Enter the name of the steg file: " stegfile
#read stegfile

read -p "Enter the name of the word list: " wordlist
#read wordlist

FILE="$wordlist"

while read line; do
	#steghide extract -p $line -sf pic.bmp >> output 2>&1
	#echo $line
	#check=`grep -c 'wrote' output`
	#echo $check
	if [ `steghide extract -p $line -sf $stegfile 2>&1 | grep -c 'wrote'` -gt 0 ]; then
		echo $line
		exit
	fi
done < $FILE
	

