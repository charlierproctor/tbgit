require "tbgit/version"
require "tempfile"
require "score_parser"
require "add_webhooks"
require 'highline/import'
require "optparse"

module Main

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
  	def on_each_gather
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
  	
  	def spec(args)

  		options = {}
		opt_parser = OptionParser.new do |opts|
		  	opts.banner = "Usage: tbgit spec [options]"

		  opts.on("-y", "--yes","Proceed without asking for confirmation") do |y|
		    options[:yes] = y
		  end

		  opts.on("-f", "--specfile FILE", "Specify the relative path from your pwd 
		  	to the rspec file you would like to spec, eg. 'hw1/spec/spec.rb'") do |f|
		  	options[:specfile] = f
		  end

		  opts.on("-s", "--studentcopy FILE", "Specify where you would like to save each 
		  	student's individual results. Must be inside the student's repo directory,
		  	eg. 'hw1/spec/results.txt'") do |s|
		  	options[:studentcopy] = s 
		  end

		  opts.on("-t", "--teachercopy FILE", "Specify where you would like to save a copy
		  	of all results. Must be outside the student's repo directory, eg. '../results'") do |t|
		  	options[:mastercopy] = t
		  end

		  opts.on("-m", "--message MESSAGE", "Specify the commit message 
		  	(commiting each student's results to their repo)") do |m|
		  	options[:message] = m 
		  end

		  opts.on("-n", "--studentname NAME", "If you would like to spec an individual student,
		  	please specify their name. Otherwise, use the --all option to spec all students.") do |n|
		  	options[:student] = n 
		  end

		  opts.on("-a", "--all", "Use this option to spec all student homework.")

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
	  	if options[:student]==nil && !options[:all]
	  		puts "Please specify a student to spec. Type 'all' to spec all students"
	  		student = $stdin.gets.chomp
	  	elsif options[:student]!=nil && !options[:all]
	  		student = options[:student]
	  	elsif options[:student]!=nil && options[:all]
	  		raise "-n,--student and -a,--all cannot be used at the same time!"
	  	else
	  		all = true
	  	end

	  	if student == "all"
	  		all = true
	  	end

	  	if  all
	  		confirm(options[:yes],"'rspec " + specfile + "' will be executed on each student's local branch. 
	  			Individual results will be saved to " + studentcopy + " and master results to " + mastercopy + ". Continue?")

	  		on_each_exec(["rspec " +specfile + " > " + studentcopy,   	#overwrite
	  			"rspec --format json --out " + mastercopy + "/<branch> " + specfile,
	  		 	"git add --all",
	  		 	"git commit -am '" + commit_message + "'",
	  		 	"git push <branch> <branch>:master"])
	  	else
	  	#TODO -- individual student spec throws error
	  		system("git checkout " + student)
	  		system("rspec " + specfile + " > " + studentcopy)
	  		system("rspec --format json --out " + mastercopy + "/<branch> " + specfile)
	  		system("git add --all")
	  		system("git commit -am '" + commit_message + "'")
	  		system("git push <branch> <branch>:master")
			switch_to_master

	  	end

  	 	my_parser = Parser.new
  	 	my_parser.score_parse(mastercopy)

  	end

  	def add_webhooks(organization,reponame,user,pass,url)
  		if organization == nil
  			puts "Organization Name:"
  			organization = $stdin.gets.chomp
  		end

  		if reponame == nil
  			puts "Student Repository Name:"
  			reponame = $stdin.gets.chomp
  		end

  		if user == nil
  			print "Username:"
  			user = $stdin.gets.chomp
  		end

  		if pass == nil
  			pass = ask("Password: ") { |q| q.echo = false }
  		end

  		if url == nil
  			puts "Webhook url:"
  			url = $stdin.gets.chomp
  		end

  		on_each_ruby(['create = CreateWebhooks.new; create.post(\''+ organization.to_s + '\',\'<branch>\',\''+reponame.to_s+'\',
  				\''+user.to_s+'\',\''+pass.to_s+'\',\''+url.to_s+'\')'])

  	end
  end #class
end #module
