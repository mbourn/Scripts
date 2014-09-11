#!/bin/bash
###############################################################################
#  Written  by: mbourn
#  Written  on: 9/17/13
#  Description: This is a script that takes a basic NMap scan file as input and
#  parses it to produce more concise output.  Each line is FQDN of the server, 
#  the IP address of the server, port number/[tcp|udp], [open|closed], 
#  responding service, responding application name, application verison number
###############################################################################

###############################
## die()
## A simple function to echo an error msg and kill the program.
die(){
  echo >&2 "$@"
  exit 1
}
########################
####  Main Program #####
########################

#  Check the argument for correctness
[ "$#" -eq 0 ] && die "Error: You must specify a log file. Exiting."
[ "$#" -gt 1 ] && die "Error: You have entered too many arguments. Exiting."
[ -e $1 ] || die "Error: Couldn't open the file. Exiting."

#  Refresh temp and output files if they exists
[ -e temp ] && rm temp
[ -e openPortReport ] && rm openPortReport

#  Enter the names of your internal servers here.
#  Go through output and only select the lines with the info we want
awk '/^([0-9])|(server1)|(server2)|(server3)|(server4)|(server5)|(server6)/ { print }' out > temp

#  Go through the targetted output and put the server name and address in front
#+ of the open ports on that server
while read LINE; do
  server=$(echo "$LINE" | awk '/^Nmap/ {print $5,$6}')
  if [ "$server" != "" ]; then
    serverName="$server "
  else
    echo -n "$serverName"
    echo "$LINE" | awk '/^[0-9]/ {print}'
  fi
#  Shrink multiple spaces into a single space, turn all spaces into commas, and
#+ then remove the parentheses around the IP address
done < temp | tr -s ' ' | tr ' ' ',' | tr -d '()' >> openPortReport

#  Clean up my mess
[ -e temp ] && rm temp
