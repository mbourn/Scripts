#!/usr/bin/ruby
###############################################################################
#  Written  by: mbourn
#  Written  on: 9/5/14
#  Description: This is a script that searches the current directory, and all
#               subdirectories, for either filenames or text files containing
#               a specified string.  It then prints the results to the screen.
#               This is the long, readable version with verbose comments. 
###############################################################################

#  This line executes a bash command that lists all current and 
## subdirectories.  The result is saved in a variable
directory_string=`find .`

#  This line splits the string from above into an array using the
## \n between each line as the split between elements
array_of_paths=directory_string.split("\n").sort!

#  This prints the first section of results.  It loops through the array
## searching for filenames that contain the specified string and end in a
## specific file extension.
puts "Files with names that matches <#{ARGV[0]}>"
array_of_paths.each do |path|
	if ( path=~/.*#{ARGV[0]}\.((rb)|(erb)|(js)|(css)|(html)|(yml)|(txt))$/ )
		puts "  #{path}"
	end
end
puts "*" * 50

#  This prints the second section.  It loops through the array, testing
## each element to see if it contains a full path to a file, then testing that
## file to see if it has the proper file extension, greping it if it does, and
## printing the results if any are found.  The variable is used to prevent the
## script from printing a line of dashes if the output it is the first time 
## the script has printed in this section.
not_first_pass=0
puts "Files with content that matches <#{ARGV[0]}>"
array_of_paths.each do |path|
	if ( path=~/.*\.((rb)|(erb)|(js)|(css)|(html)|(yml)|(txt))$/ )
		grep_result=`grep -ni \'#{ARGV[0]}\' #{path}`
		if ( grep_result.size > 0)
			not_first_pass==1 ? puts('-' * 50) : not_first_pass = 1 
			puts path
			grep_result_array=grep_result.split("\n")
			grep_result_array.each do |found_word| 
				puts "  #{found_word}"
			end
		end
	end
end