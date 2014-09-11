#!/bin/bash
###############################################################################
#  Written  by: mbourn
#  Written  on: 4/8/14
#  Description: This is a script that takes the access log from a web sever as
#               input.  There are several flags and options to choose from but,
#               basically it parses the log for messages (e.g. 404), records 
#               accessed, requester address, etc on a certain date or within a 
#               range of dates.  It features a function that dynamically 
#               a regular expression for matching dates, my first use of a help
#               flag, and my first use of a die() function.
###############################################################################
## Define the die() function
# Kills the script and outputs an error message
die(){
  echo >&2 "$@"
  exit 1
}

## Define getRange() function
# This function takes two numbers and generates a regex to select every number
#+ in the specefied range of numbers, i.e. getRange 1 3 will generate
#+ (([0][1])|([0][2])|([0][3]))
getRange(){
  ctr="$1"
  rex="("
  while [ "$ctr" -le "$2" ]; do
    [ "$ctr" -lt 10 ] && rex="$rex ([0][$ctr])"
    [ "$ctr" -gt 9 ] && rex="$rex ([$(( $ctr / 10))][$(( $ctr % 10 ))])"
    [ "$ctr" -ne "$2" ] && rex="$rex |"
    let ctr=$ctr+1
  done
  rex="$rex )"
  output=`echo "$rex" | tr -d ' '` 
  echo $output
}

## Define the valid_args() function
# Checks the args to make sure they are a valid combination of flags and values
valid_args(){
  # There must be at least one arg
  [ "$#" -gt 0 ] || die "At least 1 argument is required."
  
  # If the --help flag is set, it can be the only argument
  [ "$1" != "--help" ] || [ "$#" -lt 2 ] || die "Too many arguments. Please retry using only \"log_parse.sh --help\""
  
  # If the first arg is not "--help" then the second arg must be "--day"
  [ "$1" == "--help" ] || [ "$2" == "--day" ] || die "You must use the --day command"
  
  # If the first arg is not "--help" then the third arg must be a number between
  # 1 and 28 or a range between those numbers
  if [ "$1" != "--help" ]; then
    dayRange=`echo "$3" | grep -cE "^(([1-9]-[2-9])|([1-9]-[1][0-9])|([1-9]-[2][0-8])|([1][0-9]-[1][1-9])|([1][0-9]-[2][0-8])|([2][0-7]-[2][1-8]))$"`
    daySingle=`echo "$3" | grep -cE "^(([1-9])|([1][0-9])|([2][0-8]))$"`
    if [ "$dayRange" -eq 0 ]; then
      if [ "$daySingle" -eq 0 ]; then
        die "Invalid day format. Please see log_parse.sh --help for more information"
      fi
    fi
  # If a range of dates is given, make sure it is valid
    if [ "$res" -eq 1 ]; then
      OIFS=$IFS
      IFS='-'
      arr=$3
      y=1
      for x in $arr
      do
        declare -i dayRange$y=$x
        let y=$y+1
      done
      IFS=$OFS
      [ "$dayRange1" -ge "$dayRange2" ] && die "Invalid date range. Please see log_parse.sh --help for more information"
    fi
  fi
  
  # If the --number flag is used, check that a number is entered  
  [ "$1" != "--help" ] && [ "$4" != "--number" ] || [ `expr $5 + 1 2> /dev/null` ] || die "Please enter the number of entries to display"
  
  # If the first arg is not "--help" check that the log file is valid
  [ "$1" == "--help" ] || [ -f "${!#}" ] || die "The log file or path you entered is invalid."
  
  # Test to make sure the first arg is a valid arg
  if [ "$1" != "--help" ]; then
    if [ "$1" != "--resources" ]; then
      if [ "$1" != "--requesters" ]; then
        if [ "$1" != "--errors" ]; then
          if [ "$1" != "--hourly" ]; then
            die "Invalid flag.  Please see log_parse.sh --help for more information"
          fi
        fi
      fi
    fi
  fi
}

## Define the help() function
# Displays the help message
help(){
  echo -e "\nUsage: log_parse [--type] [--day #|#-#] [options] [/path/to/logfile]\n"
  echo "  The --type argument is required.  The types of searches are:"
  echo "    --resources"
  echo "      Displays a list of the resources requested and the number of times"
  echo "      they were requested sorted from most requsted to least"
  echo "    --requesters"
  echo "      Displays a list of the hosts/IP addresses that requested resources and"
  echo "      the number of request made, sorted from most to least."
  echo "    --errors"
  echo "      Displays the number of time a resource was requested and the request"
  echo "      returned an error sorted from most to least."
  echo "    --hourly"
  echo "      Counts the number of requests received, sorts and then displays them"
  echo -e "      by the hour in which the request was received.\n"
  echo "  The --day argument is required and defines the day, or range of days, to" 
  echo "  be parsed.  The format is --day 12 | --day 9-20"
  echo "  The only option currently available is --number. Options are optional."
  echo "    --number #"
  echo "      This option causes the script to display only the top # results."
  echo -e "      The format is --number 10\n"
  echo "  Examples:"
  echo "    log_parse.sh --resources --day 12-15 access_log_Jul95"
  echo -e "    log_parse.sh --hourly --day 7 --number 100 access_log_Jul95\n"
  
}

################################################################################
## Define resource() function
# Displays the number of times a resource has been requested during the 
# specified date range
resources(){
#  echo "Resources"
  if [ -f temp ]; then
    rm temp
    touch temp
  fi
  if [ -f trunc ]; then
    rm trunc
    touch trunc
  fi
  # Determine if the --day flag has a single day or a range of days
  dayRange=`echo "$3" | grep -cE "^(([1-9]-[2-9])|([1-9]-[1][0-9])|([1-9]-[2][0-8])|([1][0-9]-[1][1-9])|([1][0-9]-[2][0-8])|([2][0-7]-[2][1-8]))$"`
  daySingle=`echo "$3" | grep -cE "^(([1-9])|([1][0-9])|([2][0-8]))$"`
  
## <---- Above should be in main() ----->
  
  # If --day is a single day 
  if [ "$daySingle" -eq 1 ]; then
    # And that day is between 1-9
    if [ "$3" -lt 10 ]; then
      # And the --number flag is not set
      if [ "$4" != "--number" ]; then
        awk '{ print $4, $7 }' access_log_Jul95 | grep -E "^[[][0]$3\/." > trunc
        awk '{ print $2 }' trunc | sort | uniq -c | sort -nr > temp
      # Or if the --number flag is set
      elif [ "$4" == "--number" ]; then
        awk '{ print $4, $7 }' access_log_Jul95 | grep -E "^[[][0]$3\/." > trunc
        awk '{ print $2 }' trunc | sort | uniq -c | sort -nr | head -n"$5" > temp
      fi
    # Or that day is between 10-28
    elif [ "$3" -gt 9 ]; then
      # And the --number flag is not set
      if [ "$4" != "--number" ]; then
        awk '{ print $2 }' trunc | sort | uniq -c | sort -nr > temp
      elif [ "$4" == "--number" ]; then
        awk '{ print $2 }' trunc | sort | uniq -c | sort -nr | head -n"$5" > temp
      fi
    fi
  elif [ "$dayRange" -eq 1 ]; then
    # Put the starting and ending days into seperate vars
    OIFS=$IFS
    IFS='-'
    arr=$3
    y=1
    for x in $arr
    do
      declare -i dayRange$y=$x
      let y=$y+1
    done
    IFS=$OFS
    
    # Turn the day range into a regex
    regex=$(getRange $dayRange1 $dayRange2)

    # Select matching lines from the log file and save them in trunc
    awk '{ print $4, $7 }' access_log_Jul95 | grep -E "[[]$regex\/." > trunc
:<<XXXXX
    while [ "$counter" -le "$dayRange2" ]; do
      # While the starting number in the date range is < 10, use this regex
      if [ "$counter" -lt 10 ]; then
        awk '{ print $4, $7 }' access_log_Jul95 | grep -E "^[[]0$counter\/." >> trunc
      # While the starting number in the date range is > 9, use this regex
      else
        awk '{ print $4, $7 }' access_log_Jul95 | grep -E "^[[]$counter\/." >> trunc
      fi
      let counter=$counter+1
    done
XXXXX

    # If the --number flag is not set, sort, truncate, condense, and resort by number
    if [ "$4" != "--number" ]; then
      awk '{ print $2 }' trunc | sort | uniq -c | sort -nr > temp

    # If the --number flag is not set, sort, truncate, condense, and resort by
    #+ number then return the top n results
    elif [ "$4" == "--number" ]; then
      awk '{ print $2 }' trunc | sort | uniq -c | sort -nr | head -n"$5" > temp
    fi
  else
    die "I'm not sure what happened, but it was bad"
  fi
}

################################################################################
## Define requesters() function
# Displays a list of the number of times each IP address has requested a 
# resource
requesters(){
  echo "Requesters"
  if [ -f temp ]; then
    rm temp
    touch temp
  fi
  if [ -f trunc ]; then
    rm trunc
    touch trunc
  fi
  # Determine if the --day flag has a single day or a range of days
  dayRange=`echo "$3" | grep -cE "^(([1-9]-[2-9])|([1-9]-[1][0-9])|([1-9]-[2][0-8])|([1][0-9]-[1][1-9])|([1][0-9]-[2][0-8])|([2][0-7]-[2][1-8]))$"`
  daySingle=`echo "$3" | grep -cE "^(([1-9])|([1][0-9])|([2][0-8]))$"`
  
  # If the date range is a single day
  if [ "$daySingle" -eq 1 ]; then
  
    # If the day is between 1-9 grab the designated date range
    if [ "$3" -lt 10 ]; then
      awk '{ print $4, $1 }' access_log_Jul95 | grep -E "^[[][0]$3\/." > trunc
      # If the --number flag is not set
      if [ "$4" != "--number" ]; then
        awk '{ print $2 }' trunc | sort | uniq -c | sort -nr > temp
      # If if the --number flag is set
      elif [ "$4" == "--number" ]; then
        awk '{ print $2 }' trunc | sort | uniq -c | sort -nr | head -n"$5" > temp
      fi
      
    # If the day is between 10-28
    elif [ "$3" -gt 9 ]; then
      # And the --number flag is not set
      if [ "$4" != "--number" ]; then
        awk '{ print $2 }' trunc | sort | uniq -c | sort -nr > temp
      elif [ "$4" == "--number" ]; then
        awk '{ print $2 }' trunc | sort | uniq -c | sort -nr | head -n"$5" > temp
      fi
    fi
    
  # If the date range is a range of days
  elif [ "$dayRange" -eq 1 ]; then
    # Put the starting and ending days into seperate vars
    OIFS=$IFS
    IFS='-'
    arr=$3
    y=1
    for x in $arr
    do
      declare -i dayRange$y=$x
      let y=$y+1
    done
    IFS=$OFS
    
    # Turn the day range into a regex
    regex=$(getRange $dayRange1 $dayRange2)

    # Select matching lines from the log file and save them in trunc
    awk '{ print $4, $1 }' access_log_Jul95 | grep -E "[[]$regex\/." > trunc

:<<XXXXXX    
    declare -i counter="$dayRange1"
    while [ "$counter" -le "$dayRange2" ]; do
      # While the starting number in the date range is < 10, use this regex
      if [ "$counter" -lt 10 ]; then
        awk '{ print $4, $1 }' access_log_Jul95 | grep -E "^[[]0$counter\/." >> trunc
      # While the starting number in the date range is > 9, use this regex
      else
        awk '{ print $4, $1 }' access_log_Jul95 | grep -E "^[[]$counter\/." >> trunc
      fi
      let counter=$counter+1
    done
XXXXXX

    # If the --number flag is not set, sort, truncate, condense, and resort by number
    if [ "$4" != "--number" ]; then
      awk '{ print $2 }' trunc | sort | uniq -c | sort -nr > temp
    # If the --number flag is not set, sort, truncate, condense, and resort by
    #+ number then return the top n results
    elif [ "$4" == "--number" ]; then
      awk '{ print $2 }' trunc | sort | uniq -c | sort -nr | head -n"$5" > temp
    fi
  else
    die "I'm not sure what happened, but it was bad"
  fi
}
################################################################################
## Define errors() function
# Displays all requests that returned an error within the specified date range
errors(){
  echo "Errors"
  # Clear temporary files if they are present
  if [ -f temp ]; then
    rm temp
    touch temp
  fi
  if [ -f trunc ]; then
    rm trunc
    touch trunc
  fi
  # Determine if the --day flag has a single day or a range of days
  dayRange=`echo "$3" | grep -cE "^(([1-9]-[2-9])|([1-9]-[1][0-9])|([1-9]-[2][0-8])|([1][0-9]-[1][1-9])|([1][0-9]-[2][0-8])|([2][0-7]-[2][1-8]))$"`
  daySingle=`echo "$3" | grep -cE "^(([1-9])|([1][0-9])|([2][0-8]))$"`
  
# If --day is a single day 
  if [ "$daySingle" -eq 1 ]; then
    # If the day is between 1-9
    if [ "$3" -lt 10 ]; then
      awk '{ print $4, $7, $9 }' access_log_Jul95 | grep -E "^[[][0]$3.*\s.*\s(([4][0][0])|([5][0][0]))$" > trunc

      # If the --number flag is not set
      if [ "$4" != "--number" ]; then
        awk '{ print $2, $3 }' trunc | sort | uniq -c | sort -nr > temp
      # If the --number flag is set
      elif [ "$4" == "--number" ]; then
        awk '{ print $2, $3 }' trunc | sort | uniq -c | sort -nr | head -n"$5" > temp
      fi
      
    # If the day is between 10-28
    elif [ "$3" -gt 9 ]; then
      awk '{ print $4, $7, $9 }' access_log_Jul95 | grep -E "^[[]$3.*\s.*\s(([4][0][0])|([5][0][0]))$" > trunc
      
      # And the --number flag is not set
      if [ "$4" != "--number" ]; then
        awk '{ print $2, $3 }' trunc | sort | uniq -c | sort -nr > temp
      elif [ "$4" == "--number" ]; then
        awk '{ print $2, $3 }' trunc | sort | uniq -c | sort -nr | head -n"$5" > temp
      fi
    fi
    
  elif [ "$dayRange" -eq 1 ]; then
    # Put the starting and ending days into seperate vars
    OIFS=$IFS
    IFS='-'
    arr=$3
    y=1
    for x in $arr
    do
      declare -i dayRange$y=$x
      let y=$y+1
    done
    IFS=$OFS
    
    # Turn the day range into a regex
    regex=$(getRange $dayRange1 $dayRange2)

    # Select matching lines from the log file and save them in trunc
    awk '{ print $4, $7, $9 }' access_log_Jul95 | grep -E "[[]$regex.*\s.*\s(([4][0][0])|([5][0][0]))$" > trunc
    
    # If the --number flag is not set, sort, truncate, condense, and resort by number
    if [ "$4" != "--number" ]; then
      awk '{ print $2, $3 }' trunc | sort | uniq -c | sort -nr > temp
    # If the --number flag is not set, sort, truncate, condense, and resort by
    #+ number then return the top n results
    elif [ "$4" == "--number" ]; then
      awk '{ print $2, $3 }' trunc | sort | uniq -c | sort -nr | head -n"$5" > temp
    fi
  else
    die "I'm not sure what happened, but it was bad"
  fi
}


## Define hourly() function
# Displays the number of requests that the server received during the specified
# date range.  The counts are then broken down and displayed by the hour in
# which the request was received.
hourly(){
  # Clear temporary files if they are present
  if [ -f temp ]; then
    rm temp
    touch temp
  fi
  if [ -f trunc ]; then
    rm trunc
    touch trunc
  fi

  # Determine if the --day flag has a single day or a range of days
  dayRange=`echo "$3" | grep -cE "^(([1-9]-[2-9])|([1-9]-[1][0-9])|([1-9]-[2][0-8])|([1][0-9]-[1][1-9])|([1][0-9]-[2][0-8])|([2][0-7]-[2][1-8]))$"`
  daySingle=`echo "$3" | grep -cE "^(([1-9])|([1][0-9])|([2][0-8]))$"`
  
# If --day is a single day 
  if [ "$daySingle" -eq 1 ]; then
    # If the day is between 1-9
    if [ "$3" -lt 10 ]; then
      awk '{ print $4 }' access_log_Jul95 | grep -E "^[[][0]$3.*"\
        | tr ':' ' ' | tr '[' ' ' | awk '{ print $2":00", $1 }' > trunc

      # If the --number flag is not set
      if [ "$4" != "--number" ]; then
        awk '{ print $1, $2 }' trunc | sort | uniq -c > temp
      # If the --number flag is set
      elif [ "$4" == "--number" ]; then
        awk '{ print $1, $2 }' trunc | sort | uniq -c | sort -nr | head -n"$5" > temp
      fi
      
    # If the day is between 10-28
    elif [ "$3" -gt 9 ]; then
      awk '{ print $4 }' access_log_Jul95 | grep -E "^[[]$3.*"\
        | tr ':' ' ' | tr '[' ' ' | awk '{ print $2":00", $1 }' > trunc
      
      # And the --number flag is not set
      if [ "$4" != "--number" ]; then
        awk '{ print $1, $2 }' trunc | sort | uniq -c > temp
      elif [ "$4" == "--number" ]; then
        awk '{ print $1, $2 }' trunc | sort | uniq -c | sort -nr | head -n"$5" > temp
      fi
    fi
    
  elif [ "$dayRange" -eq 1 ]; then
    # Put the starting and ending days into seperate vars
    OIFS=$IFS
    IFS='-'
    arr=$3
    y=1
    for x in $arr
    do
      declare -i dayRange$y=$x
      let y=$y+1
    done
    IFS=$OFS
    
    # Turn the day range into a regex
    regex=$(getRange $dayRange1 $dayRange2)

    # Select matching lines from the log file and save them in trunc
    awk '{ print $4 }' access_log_Jul95 | grep -E "[[]$regex.*"\
      | tr ':' ' ' | tr '[' ' ' | awk '{ print $2":00", $1 }' > trunc
    
    # If the --number flag is not set, sort, truncate, condense, and resort by number
    if [ "$4" != "--number" ]; then
      awk '{ print $2, $1 }' trunc | sort | uniq -c > temp
    # If the --number flag is not set, sort, truncate, condense, and resort by
    #+ number then return the top n results
    elif [ "$4" == "--number" ]; then
      awk '{ print $2, $1 }' trunc | sort | uniq -c | sort -nr | head -n"$5" > temp
    fi
  else
    die "I'm not sure what happened, but it was bad"
  fi
}

# Call the function to validate the arguments used


case "$1" in
  "--help")
    help
  ;;
  "--resources")
    resources $@
  ;;
  "--requesters")
    requesters $@
  ;;
  "--hourly")
    hourly $@
  ;;
  "--errors")
    errors $@
  
  ;;
  esac


