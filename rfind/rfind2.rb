#!/usr/bin/ruby
not_first_pass = 0
puts "Files with names that matches <#{ARGV[0]}>"
((array_of_paths=(directory_string=`find .`).split("\n")).sort!).each do |path|
	if ( path=~/.*#{ARGV[0]}\.((rb)|(erb)|(js)|(css)|(html)|(yml)|(txt))$/ )
		puts "  #{path}"
	end
end
puts "**************************************************\nFiles with content that matches <#{ARGV[0]}>"
array_of_paths.each do |path|
	if ( path=~/.*\.((rb)|(erb)|(js)|(css)|(html)|(yml)|(txt))$/ )
		if ( (grep_result=`grep -ni \'#{ARGV[0]}\' #{path}`).size > 0)
			not_first_pass==1 ? puts("--------------------------------------------------") : not_first_pass = 1 
			puts path
			(grep_result_array=grep_result.split("\n")).each do |found_word| 
				puts "  #{found_word}"
			end
		end
	end
end