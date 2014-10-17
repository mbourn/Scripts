#!/bin/bash

#  Get the files to be worked on from the user
read -p "Enter the name of the steg file: " stegfile
read -p "Enter the name of the word list: " wordlist
count=0

#  Read through the word list until the password is found or the end is reached
while read line; do

	#  Print out the count every 100,000 tries to let the user know the program 
	#+  is still working
	((count++))
	[ `expr $count % 100000` -eq 0 ] && echo $count
    
	#  Capture the result of the steghide command.  Test the results to 
	#+ determine what to do next
    result=`steghide extract -p $line -sf $stegfile 2>&1` 
    case $result in

    	#  The password was found and the embedded file was extracted
    	*"wrote"*) echo "The password is $line"
				   exit;;
		#  The password was found but there is a file in the current directory
		#+ that has the same name as the file to be extracted.  Print 'n' to  
		#+ prevent the overwrite, print an explaination to the user.
		*"overwrite"*) echo n
					   echo "------------------------------------------------"
					   echo "There is a file in this directory with the same name as the embedded file."
					   echo "The embedded file cannot be extracted until this conflict is resolved."
					   echo "The password is:  $line."
					   exit;;
	esac
done < $wordlist
	

