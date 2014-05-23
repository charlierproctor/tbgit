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

  		all_remotes = all_remotes_list
  		all_remotes.each do |branch|
  			branch.delete!("\n")

  			if branch != "origin"
	  			checkout_command = "git checkout " + branch 
	  			merge_command = "git merge --no-commit " + merge_branch.to_s
	  		  	stage_changes = "git add --all"		
	  			commit_command = "git commit -am '" + message + "'"

	  			puts checkout_command
	  			system checkout_command

	  			puts merge_command
	  			system merge_command

	  			puts stage_changes
	  			system stage_changes

	  			puts commit_command
	  			system commit_command
	  		end

  		end

	  		switch_to_master

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
  		all_remotes.each do |branch|
  			branch.delete!("\n")

  			if branch != "origin"
		  		checkout_command = "git checkout " + branch 

		  		puts checkout_command
		  		system checkout_command

	  			input.each do |command|
	  				final_command = command.gsub("<branch>", branch)

	  				puts final_command
	  				system final_command
	  			end
  			end

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

  	def help
  		puts ""
  		puts "TBGit is a command-line utility to facilitate the management of multiple GitHub student repositories."
  		puts "			~ created by Charlie Proctor at 2014 YEI Tech Bootcamp"
  		puts "						~ partly based off of https://github.com/education/teachers_pet"
  		puts "	Commands:"
  		puts "		~ setup   	sets up a tbgit environment. See decription below"
  		puts "		~ push  	pushes all local student branches to their remote master branches"
  		puts "		~ pull   	pulls all remote master branches to local student branches"
  		puts "		~ merge   	merges a specified branch with each student branch and then commits the changes"
  		puts "		~ status 	runs `git status` on each students branch and displays the results"
  		puts "		~ each 		executes a specified series of commands on each local student branch"
  		puts "		~ spec 		runs rspec on specified files in a students repo"
  		puts ""
  		puts "		~ add-remotes  	adds each student's repository as a remote"
  		puts "		~ create-locals 	creates a local branch to track the students remote master branch"
  		puts "			^----> these are both part of the setup process"
  		puts ""
  		puts "	TBGit Environment"
  		puts "		~ it's a regular git repository -- with lots of fancy features!"
  		puts "		~ there is a master branch for teachers to work off of (create hw files, etc..)"
  		puts "				--> teachers can obviously create and work off other branches if desired"
  		puts "		~ each student's repository is a remote of the git repo"
  		puts "		~ there is a local branch to track each student's remote master branches"
  		puts ""
  		puts "	Setup"
  		puts "		1. Teachers create the student repositories (https://github.com/education/teachers_pet works perfectly well for this)"
  		puts "				--> make sure the repos are all private, but that you have access to them!"
  		puts "				--> initialize these repos with a README or push out a starter file."
  		puts "				--> create a file with a list of the students github usernames (one on each line)" 
  		puts "						--- you will need this during the setup process"
  		puts "		2. Teachers create a repo for themselves. This will serve as the base for the tbgit environment."
  		puts "		3. Change to that repo's directory, execute `tbgit setup`, and follow the instructions."
  		puts ""
  		puts "	A Typical Workflow"
  		puts "		1. Teachers create the assignment (on the master branch) and make a final commit when they're ready to deploy it"
  		puts "		2. Teachers pull all the students' repos to make sure they're up to date."
  		puts "				--> `tbgit pull`"
  		puts "		3. Teachers merge their master branch with each student's local branch"
  		puts "				--> `tbgit merge`"
  		puts "		4. At this point, teachers should check to make sure their were no merge conflicts. If there were, go in and fix them."
  		puts "				--> feel free to `git checkout <username>` a few different branches"
  		puts "		4. Teachers push each students local branch to the student's remote master branch"
  		puts "				--> `tbgit push`"
  		puts "		5. Make sure it worked.  Do a victory lap."
  		puts ""
  		puts "		To view student solutions at any point, just `tbgit pull` and `git checkout <username>`"
  		puts ""
  	end





  end #class
end #module
