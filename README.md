Scripts
=======

A collection of scripts written for school.  Most aren't terribly useful
by themselves but may contain interesting bits here and there.

fileTree
----------------
This is a ruby script creates a text-based, simulated file 
tree.  The user can add and remove files, directories, and
links as well as display the current tree.  Files, links, and 
directories can be nested to an arbitrary deapth.  No actual
files, links, or directories are created on the host system, it
is just a simulation.  It features a few recursive functions 
that walk the tree.  This was the first program I created in
ruby and it was an interesting way to learn the language.

httpLogParse
----------------
This is a script that takes the access log from a web sever as
input.  There are several flags and options to choose from but,
basically it parses the log for messages (e.g. 404), records 
accessed, requester address, etc on a certain date or within a 
range of dates.  It features a function that dynamically 
a regular expression for matching dates, my first use of a help
flag, and my first use of a die() function.

lottoGen
----------------
This is a script that generates a string of pseduo random 
numbers.  The user is prompted to choose the maximum vaule
that any number may have, the quantity of numbers to be 
generated per sequence, and the number of sequences to be
genereated.  Part of the assignment was to do excessive error
handling, which is why there is excessive error handling.

nmapLogParse
----------------
This is a script that takes a basic NMap scan file as input and
parses it to produce more concise output.  Each line is FQDN of the server, 
the IP address of the server, port number/[tcp|udp], [open|closed], 
responding service, responding application name, application verison number.

rfind
----------------
This is a script that searches the current directory, and all
subdirectories, for either filenames or text files containing
a specified string.  It then prints the results to the screen.
This is the long, readable version with verbose comments.  I'm
told that this will be a very useful tool when I begin programming
with ruby on rails.

rfind2
----------------
This does the same thing as rfind, but the code is more dense and dificult to read, which I'm told makes it cooler.  Using the basic ideas I have here for tackling the problem, my Prof. was able to condense the code even further than this to 10 lines.

stegBrute
----------------
For a capture the flag event we had to extract a flag that was embedded in a .bmp using steganography.
The embedded file was password protected, so I wrote this script to brute crack the password using
steghide and a user-supplied word list.  I'm currently making it a little cleaner, faster, and  more
functional.  In the future I'd like to rewrite it to use threads to improve the speed.
