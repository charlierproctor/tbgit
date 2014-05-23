require "tbgit/version"
require "tempfile"

module Main

  class TBGit

  	def spacer
  		puts "********************************************************************************"
  	end

  	#confirms a given message
  	def confirm(message)
  		print message + " (y/n)  "
  		response = $stdin.gets.chomp
  		if response == 'y'
  			#do nothing
  		else
  			exit
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
    def gather
    	puts 'Students file |../students|:'
    	@students_file = $stdin.gets.chomp
    	if @students_file == ""
    		@students_file = "../students"
    	end

    	puts 'Organization name |yale-stc-developer-curriculum|:'
    	@organization = $stdin.gets.chomp
    	if @organization == ""
    		@organization = "yale-stc-developer-curriculum"
    	end

    	puts 'Student Repo Name |TechBootcampHomework|:'
    	@reponame = $stdin.gets.chomp
    	if @reponame == ""
    		@reponame = "TechBootcampHomework"
    	end
    end

    #update remotes
	def git_update
		puts "git remote update"
 		system "git remote update"
 	end

    #add each student repository as a remote
    def add_remotes
    	confirm("Each student repository will be added as a remote. Continue?")
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
 		confirm("Local branches will be created to track remote student repositories. Continue?")
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
  	def update_repos(pushpull)
  		if pushpull == "push"
  			confirm("Each local student branch will be pushed to their remote master branch. Continue?")
			on_each_exec(["git push <branch> <branch>:master"])
  		else
  			confirm("Each remote student master branch will be pulled to the local branch. Continue?")
			on_each_exec(["git pull <branch> master"])
		end
  	end

  	#merges from master (or another branch) to each student branch and commits the changes
  	def merge_and_commit

  		confirm("A merge and commit will be performed on each local student branch (from the branch you specify). Continue?")
  		puts "Merge from branch: "
  		merge_branch = $stdin.gets.chomp

  		puts "Commit Message: "
  		message = $stdin.gets.chomp

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

  	#takes an array of commands, and executes each command on each student branch
  	def on_each_exec(input)   
  		all_remotes = all_remotes_list
  		output_array = Array.new

  		all_remotes.each do |branch|
  			Thread.new{
  				branch.delete!("\n")

	  			if branch != "origin"
			  		checkout_command = "git checkout " + branch 

			  		results = checkout_command
			  		results += system checkout_command

		  			input.each do |command|
		  				final_command = command.gsub("<branch>", branch)

		  				results += final_command
		  				results += system final_command
		  			end
	  			end

	  			output_array += results
  			}

  		end

  		output_array.each do |output|
  			puts output
  		end

  		switch_to_master
  	end

  	
  	def git_status
  		on_each_exec(["git status <branch>"])
  	end
  	
  	def spec
  		puts "Please specify the relative path from your pwd to the rspec file you would like to spec, eg. 'hw1/spec/spec.rb'"
  		specfile = $stdin.gets.chomp
  		puts "Where would you like to save the master copy of all results?"
  		puts "**Must be outside the student's repo directory, eg. '../results.txt'**"
  		mastercopy = $stdin.gets.chomp
  		puts "Where would you like to save each student's individual results?"
  		puts "**Must be inside the student's repo directory, eg. 'hw1/spec/results.txt'**"
  		studentcopy = $stdin.gets.chomp
  		puts "Commit message (commiting each student's results to their repo):"
  		commit_message = $stdin.gets.chomp
  		confirm("'rspec " + specfile + "' will be executed on each student's local branch. \
  			Individual results will be saved to " + studentcopy + " and master results to " + mastercopy + ". Continue?")

  		on_each_exec(["rspec " +specfile + " > " + studentcopy,   	#overwrite
  			"echo '<branch>' >> " + mastercopy,
  			"cat " + studentcopy + " >> " + mastercopy, 			#append
  		 	"git add --all",
  		 	"git commit -am '" + commit_message + "'",
  		 	"git push <branch> <branch>:master"])

  	end

  end #class
end #module
