require 'rubygems'
require 'json'

class Parser

def json_parse(string)
	JSON.parse(string)
end

def score_parse(masterfolder)	#main parsing method
	# Open master scoresheet file for writing
	ss = File.new(masterfolder + "/scoresheet.txt", "w")

	# Open each .rb file in directory and add username and failure count to scoresheet
	Dir.glob(masterfolder + '/*') do |student_result|
		if File.basename(student_result) != "scoresheet.txt"
			# Parse file into JSON and extract failure count
			file = File.open(student_result, "r")
			contents = file.read
			json = json_parse(contents)
			failure_count = json['summary']['failure_count']
			
			# Set filename to just username of student		
			filename = File.basename(student_result)
			filename.chomp(File.extname(filename))

			# Write username and failure count to score sheet
			ss << filename
			ss << ' '
			ss << failure_count
			ss << "\n"
			file.close
		end
	end

	ss.close
end
end