#! /bin/bash
###############################################################################
#  Written  by: mbourn
#  Written  on: 11/20/13
#  Description: This is a script that generates a string of pseduo random 
#               numbers.  The user is prompted to choose the maximum vaule
#               that any number may have, the quantity of numbers to be 
#               generated per sequence, and the number of sequences to be
#               genereated.  Part of the assignment was to do excessive error
#               handling, which is why there is excessive error handling.
###############################################################################
# Error Check 0 - Check for previous instance of the lottoNumbers file
if [ -e lottoNumbers ]
then
  clear; echo "Please copy your previous lotto numbers located in file \"lottoNumbers\""
  echo "After you have copied your numbers, please rename or remove lottoNumbers"
  echo "and then restart the script."
  exit
fi

# Error Check 1 - Make sure the user is old enough to gamble
read -p "Please enter your age: " age
if [ $age -lt 18 ]
then
  clear; echo "You must be at least 18 years old to gamble in this state."
  sleep 2
  clear; echo "The police have been notified."
  sleep 2
  clear; echo "You should probably start running."
  sleep 2
  exit
fi

# Get user parameters for the lotto numbers
read -p "Please enter the maximum random value between 0 and 49: " maxVal
read -p "Please enter the number of values to be chosen: " numVal
read -p "Please enter the number of sequences to be chosen: " numSeq

# Error Check 2 - Make sure the user enters numbers not words
echo "$maxVal" | grep  [a-z] >/dev/null
if [ $? == 0 ]
then
  echo "Error: This script takes only numeric input."
  echo "Please restart the script and enter only numbers."
  sleep 5
  exit
fi
echo "$numVal" | grep -q [a-z] >/dev/null
if [ $? == 0 ]
then
  echo "Error: This script takes only numeric input."
  echo "Please restart the script and enter only numbers."
  sleep 5
  exit
fi
echo "$numSeq" | grep -q [a-z] >/dev/null 
if [ $? == 0 ]
then
  echo "Error: This script takes only numeric input."
  echo "Please restart the script and enter only numbers."
  sleep 5
  exit
fi


# Error Check 3 - make sure there are enough numbers for unique values
if [ $numVal -gt $maxVal ]
then
  echo "Error: you cannot generate $numVal unique numbers from a pool of $maxVal possible numbers."
  echo "Please restart the script and enter different parameters."
  sleep 5
  exit
fi

touch lottoNumbers
j=0
while [ $j -lt $numSeq ]
do
  touch temp
  i=0
  dup=1
  while [ $i -lt $numVal ]
  do
    while [ $dup -eq 1 ]
    do
      rdm=$RANDOM
      if [ $rdm -gt $maxVal ]
        then
        rdm=$(( ($rdm % $maxVal) + 1 ))
      fi
      dup=`grep -cw $rdm temp`
    done
  echo -n $rdm " " >> temp
  dup=1
  i=$(( i + 1 ))
  done
  echo " " >> temp
  cat temp >> lottoNumbers
  rm temp
  j=$(( j + 1 ))
done

