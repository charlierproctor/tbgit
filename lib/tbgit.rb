require "tbgit/version"
require "tempfile"
require "add_webhooks"
require 'highline/import'
require "optparse"

class TBGit

	def spacer
		puts "********************************************************************************"
	end

	#confirms a given message
	def confirm(flag,message)
		if !flag
			print message + " (y/n)  "
			response = $stdin.gets.chomp
			if response == 'y'
				#do nothing
			else
				exit
			end
		end
	end

	#three simple git methods
	def switch_to_master
	puts "git checkout master"
	system "git checkout master"
	end
	def git_remote
	puts "git remote"
	system "git remote"
	end
	def git_branch
	puts "git branch"
	system "git branch"
	end

	#gather necessary information
	def gather(command, args)
	options = {}
	opt_parser = OptionParser.new do |opts|
		if command == "setup"
	  		opts.banner = "Usage: tbgit setup [options]"
	  	elsif command == "add-remotes"
	  		opts.banner = "Usage: tbgit add-remotes [options]"
	  	else
	  		opts.banner = "Usage: tbgit create-locals [options]"
	  	end


	  opts.on("-s", "--studentfile FILEPATH","Specify the file containing the list of students.") do |f|
	    options[:studentfile] = f
	  end
	  
	  opts.on("-o", "--organization NAME","Specify the name of the GitHub organization.") do |o|
	    options[:organization] = o
	  end

	  opts.on("-r", "--repo NAME","Specify the name of the student repositories.") do |r|
	    options[:repo] = r
	  end

	  opts.on_tail("-h", "--help", "Show this message") do
	    puts opts
	    exit
	  end
	end

	opt_parser.parse!(args)

	if options[:studentfile] == nil
		puts 'Students file |../students|:'
		@students_file = $stdin.gets.chomp
		if @students_file == ""
			@students_file = "../students"
		end
	else
		@students_file = options[:studentfile]
	end

	if options[:organization] == nil
		puts 'Organization name |yale-stc-developer-curriculum|:'
		@organization = $stdin.gets.chomp
		if @organization == ""
			@organization = "yale-stc-developer-curriculum"
		end
	else
		@organization = options[:organization]
	end

	if options[:repo] == nil
		puts 'Student Repo Name |TechBootcampHomework|:'
		@reponame = $stdin.gets.chomp
		if @reponame == ""
			@reponame = "TechBootcampHomework"
		end
	else
		@reponame = options[:repo]
	end
	end

	#update remotes
	def git_update
	puts "git remote update"
		system "git remote update"
	end

	#add each student repository as a remote
	def add_remotes
	students = IO.readlines(@students_file)
	students.each do |username|
		username.delete!("\n")
		
		puts "Adding Remote: " + username 
		remote_command = "git remote add " + username + " https://github.com/"+@organization+"/" + username + "-"+@reponame+".git" 
		puts remote_command
		system 	remote_command
	end
	end

	#create local branches to track remote student repositories
	def create_local_tracking_remotes
	    students = IO.readlines(@students_file)
		students.each do |username|
		username.delete!("\n")

		puts "Creating Local Branch to Track Remote: " + username 
		checkout_command = "git checkout --track -b " + username + " remotes/" + username + "/master"
		puts checkout_command
		system  checkout_command

	end

	end

	#returns a list of students
	def all_remotes_list
		remote_file = Tempfile.new("remotes")
		system "git remote >> " + remote_file.path

		puts "git remote >> " + remote_file.path

		return IO.readlines(remote_file)
	end

	#used for push / pull
	def update_repos(pushpull,args)

		options = {}
	opt_parser = OptionParser.new do |opts|
		if pushpull == "push"
	  		opts.banner = "Usage: tbgit push [options]"
	  	else
	  		opts.banner = "Usage: tbgit pull [options]"
	  	end

	  opts.on("-y", "--yes","Proceed without asking for confirmation") do |y|
	    options[:yes] = y
	  end

	  opts.on_tail("-h", "--help", "Show this message") do
	    puts opts
	    exit
	  end

	end

	opt_parser.parse!(args)


		if pushpull == "push"
			confirm(options[:yes],"Each local student branch will be pushed to their remote master branch. Continue?")
		on_each_exec(["git push <branch> <branch>:master"])
		else
			confirm(options[:yes],"Each remote student master branch will be pulled to the local branch. Continue?")
		on_each_exec(["git pull <branch> master"])
	end
	end

	def push_origin(args) #push all student branches to our origin

		options = {}
	opt_parser = OptionParser.new do |opts|
	  	opts.banner = "Usage: tbgit push-origin [options]"

	  opts.on("-y", "--yes","Proceed without asking for confirmation") do |y|
	    options[:yes] = y
	  end

	  opts.on_tail("-h", "--help", "Show this message") do
	    puts opts
	    exit
	  end
	end
	opt_parser.parse!(args)

		confirm(options[:yes],"Each local student branch will be pushed to the the origin remote. Continue?")
		on_each_exec(["git push origin <branch>"])
	end

	#merges from master (or another branch) to each student branch and commits the changes
	def merge_and_commit(args)

	options = {}
	opt_parser = OptionParser.new do |opts|
	  	opts.banner = "Usage: tbgit push-origin [options]"

	  opts.on("-y", "--yes","Proceed without asking for confirmation") do |y|
	    options[:yes] = y
	  end

	  opts.on("-b", "--branch BRANCH", "Specify the branch to merge from") do |b|
	  	options[:branch] = b
	  end

	  opts.on("-m", "--message MESSAGE", "Specify the commit message for the merge.") do |m|
	  	options[:message] = m 
	  end

	  opts.on_tail("-h", "--help", "Show this message") do
	    puts opts
	    exit
	  end
	end
	opt_parser.parse!(args)

		confirm(options[:yes],"A merge and commit will be performed on each local student branch (from the branch you specify). Continue?")
		
		if options[:branch] == nil
			puts "Merge from branch: "
			merge_branch = $stdin.gets.chomp
		else
			merge_branch = options[:branch]
		end

		if options[:message] == nil
			puts "Commit Message: "
			message = $stdin.gets.chomp
		else
			message = options[:message]
		end

	commands = ["git merge --no-commit " + merge_branch.to_s,
			  		"git add --all",
					"git commit -am '" + message + "'"]
		on_each_exec(commands)

	end

	#gathers the commands to be executed, and then calls on_each_exec(input)
	def on_each_gather(args)

		options = {}
		opt_parser = OptionParser.new do |opts|

		  opts.on("-f", "--file FILENAME", "Execute the commands specified in a certain file. One command per line. '<branch>' will be replaced by the name of the current student branch checked out.") do |f|
		  	options[:file] = f
		  end

		  opts.on("-y", "--yes","Proceed without asking for confirmation") do |y|
		    options[:yes] = y
		  end

		  opts.on_tail("-h", "--help", "Show this message") do
		    puts opts
		    exit
		  end

		end

		opt_parser.parse!(args)

		confirm(options[:yes], "The commands specified will be executed on each student branch. Continue?")

		if options[:file] == nil
			puts "Enter the commands you would like to have executed on each branch, one on each line."
			puts "'<branch>' will be replaced by the current checked-out branch. Enter a blank line to finish."
			done = false
			input = Array.new
			while !done
				text = $stdin.gets.chomp
				if text == ""
					done = true
				else
					input << text
				end
			end
		else
			input = IO.readlines(options[:file])
		end

		on_each_exec(input)

	end

	#takes an array of commands, and executes a ruby command on each student branch
	def on_each_ruby(input)   
		all_remotes = all_remotes_list
		all_remotes.each do |branch|
			branch.delete!("\n")

			if branch != "origin"
	  		checkout_command = "git checkout " + branch 

	  		puts checkout_command
	  		system checkout_command

				input.each do |command|
					final_command = command.gsub("<branch>", branch)

					puts final_command
					eval(final_command)
				end
			end

		end
		switch_to_master
	end

	#takes an array of commands, and executes a system command on each student branch
	def on_each_exec(input)
		input.map! { |a| "system '" + a.gsub("'"){"\\'"} + "'"}
		on_each_ruby(input)
	end

	def git_status
		on_each_exec(["git status <branch>"])
	end

	def add_webhooks(args)

		options = {}
		opt_parser = OptionParser.new do |opts|
		  	opts.banner = "Usage: tbgit add-webhooks [options]"

		  opts.on("-y", "--yes","Proceed without asking for confirmation") do |y|
		    options[:yes] = y
		  end

		  opts.on("-o", "--organization NAME","Specify the name of the GitHub organization.") do |o|
		    options[:organization] = o
		  end

		  opts.on("-r", "--repo NAME","Specify the name of the student repositories.") do |r|
		    options[:reponame] = r
		  end

		  opts.on("-u", "--user USERNAME", "Your GitHub username.") do |u|
		  	options[:username] = u
		  end

		  opts.on("-p", "--pass PASSWORD", "Your GitHub password.") do |p|
		  	options[:password] = p
		  end

		  opts.on("-l", "--url URL", "Webhook URL") do |l|
		  	options[:url] = l
		  end

		  opts.on_tail("-h", "--help", "Show this message") do
		    puts opts
		    exit
		  end
		end
		opt_parser.parse!(args)

		confirm(options[:yes],"Webhooks will be added to each student's GitHub repository. Continue?")

		if options[:organization] == nil
			puts "Organization Name:"
			organization = $stdin.gets.chomp
		else
			organization = options[:organization]
		end

		if options[:reponame] == nil
			puts "Student Repository Name:"
			reponame = $stdin.gets.chomp
		else
			reponame = options[:reponame]
		end

		if options[:username] == nil
			print "Username:"
			user = $stdin.gets.chomp
		else 
			user = options[:username]
		end

		if options[:password] == nil
			pass = ask("Password: ") { |q| q.echo = false }
		else 
			pass = options[:password]
		end

		if options[:url] == nil
			puts "Webhook url:"
			url = $stdin.gets.chomp
		else
			url = options[:url]
		end

		on_each_ruby(['create = CreateWebhooks.new; create.post(\''+ organization.to_s + '\',\'<branch>\',\''+reponame.to_s+'\',
				\''+user.to_s+'\',\''+pass.to_s+'\',\''+url.to_s+'\')'])

	end
end #class