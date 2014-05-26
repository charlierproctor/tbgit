require "score_parser"
require "tbgit"
require "optparse"

class TBSpec

	def spec(args)

	options = {}
	opt_parser = OptionParser.new do |opts|
  	opts.banner = "Usage: tbgit spec [options]"

	  opts.on("-y", "--yes","Proceed without asking for confirmation") do |y|
	    options[:yes] = y
	  end

	  opts.on("-f", "--specfile FILE", "Specify the relative path from your pwd to the rspec file you would like to spec, eg. 'hw1/spec/spec.rb'") do |f|
	  	options[:specfile] = f
	  end

	  opts.on("-s", "--studentcopy FILE", "Specify where you would like to save each student's individual results. Must be inside the student's repo directory, eg. 'hw1/spec/results.txt'") do |s|
	  	options[:studentcopy] = s 
	  end

	  opts.on("-t", "--teachercopy FILE", "Specify where you would like to save a copy of all results. Must be outside the student's repo directory, eg. '../results'") do |t|
	  	options[:mastercopy] = t
	  end

	  opts.on("-m", "--message MESSAGE", "Specify the commit message (commiting each student's results to their repo)") do |m|
	  	options[:message] = m 
	  end

	  opts.on("-n", "--studentname NAME", "If you would like to spec an individual student, please specify their name. Otherwise, use the --all option to spec all students.") do |n|
	  	options[:student] = n 
	  end

	  opts.on("-a", "--all", "Use this option to spec all student homework.") do|a|
	  	options[:all] = a
	  end

	  opts.on("--most-recent", "Use this option to spec the student with the most recent commit.") do |m|
	  	options[:most_recent] = m
	  end

	  opts.on("-c", "--check USERNAME", "Check to make sure that the most recent commit was NOT from the specified user.") do |u|
	  	options[:check] = u
	  end

	  opts.on("-o", "--on-completion COMMAND", "On completion of rspec testing, execute the specified command.") do |o|
	  	options[:on_completion] = 0
	  end

	  opts.on_tail("-h", "--help", "Show this message") do
	    puts opts
	    exit
	  end
	end

	opt_parser.parse!(args)

		if 	options[:specfile]==nil
			puts "Please specify the relative path from your pwd to the rspec file you would like to spec, eg. 'hw1/spec/spec.rb'"
			specfile = $stdin.gets.chomp
		else
			specfile = options[:specfile]
		end

		if options[:studentcopy]==nil
			puts "Where would you like to save each student's individual results?"
			puts "**Must be inside the student's repo directory, eg. 'hw1/spec/results.txt'**"
			studentcopy = $stdin.gets.chomp
		else
			studentcopy = options[:studentcopy]
		end

		if options[:mastercopy]==nil
			puts "In which folder would you like to save a copy of all results?"
			puts "**Must be outside the student's repo directory, eg. '../results'**"
			mastercopy = $stdin.gets.chomp
		else
			mastercopy = options[:mastercopy]
		end

		puts "mkdir " + mastercopy
		system "mkdir " + mastercopy

		if options[:message]==nil
			puts "Commit message (commiting each student's results to their repo):"
			commit_message = $stdin.gets.chomp
		else
			commit_message = options[:message]
		end

		all = false
		student = ""
		if options[:most_recent]
			most_recent_file = Tempfile.new("recent")

			command = "git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)' >> " + most_recent_file.path
			system command
			puts command
			array = IO.readlines(most_recent_file)

			student = array[0].chomp
		elsif options[:student]==nil && !options[:all]
			puts "Please specify a student to spec. Type 'all' to spec all students"
			student = $stdin.gets.chomp
		elsif options[:student]!=nil && !options[:all]
			student = options[:student]
		elsif options[:student]!=nil && options[:all]
			raise "--student and --all cannot be used at the same time!"
		else
			all = true
		end

		if student == "all"
			all = true
		end

		tbgit = TBGit.new

		if  all
			tbgit.confirm(options[:yes],"'rspec " + specfile + "' will be executed on each student's local branch. 
				Individual results will be saved to " + studentcopy + " and master results to " + mastercopy + ". Continue?")

			tbgit.on_each_exec(["rspec " +specfile + " > " + studentcopy,   	#overwrite
				"rspec --format json --out " + mastercopy + "/<branch> " + specfile,
			 	"git add --all",
			 	"git commit -am '" + commit_message + "'",
			 	"git push <branch> <branch>:master"])
		else
			system("git checkout " + student)
			output = ""
			if options[:check]!=nil
				puts "Checking to make sure last commit was not authored by: " + options[:check]
				egrep = "git log -1 | egrep " + options[:check]
				puts egrep
				output = system(egrep)
			end
			if output
				#do nothing
			else 
				puts "rspec " + specfile + " > " + studentcopy
				system("rspec " + specfile + " > " + studentcopy)
				puts "rspec --format json --out " + mastercopy + "/"+student+" " + specfile
				system("rspec --format json --out " + mastercopy + "/"+student+" " + specfile)
				puts "git add --all"
				system("git add --all")
				puts "git commit -am '" + commit_message + "'"
				system("git commit -am '" + commit_message + "'")
				puts "git push "+student+" "+student+":master"
				system("git push "+student+" "+student+":master")
				if options[:on_completion] != nil
					puts options[:on_completion]
					system(options[:on_completion])
				end
			end
		end

	 	my_parser = Parser.new
	 	my_parser.score_parse(mastercopy)

	end #method
end #class