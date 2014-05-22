require "tbgit/version"
require "tempfile"

module Main

  class TBGit

  	def spacer
  		puts "********************************************************************************"
  	end

  	#confirms a given message
  	def confirm(message)
  		puts message + " (y/n)"
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
  		else
  			confirm("Each remote student master branch will be pulled to the local branch. Continue?")
  		all_remotes = all_remotes_list
  		all_remotes.each do |branch|
  			branch.delete!("\n")

  			if branch != "origin"
	  			checkout_command = "git checkout " + branch 
	  			if pushpull == "push"
	  				pushpull_command = "git push " + branch + " " + branch + ":master"
	  			else
	  				pushpull_command = "git pull " + branch + " master"
	  			end

	  			puts checkout_command
	  			system checkout_command

	  			puts pushpull_command
	  			system pushpull_command
	  		end

	  		switch_to_master

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

	  		switch_to_master

  		end

  	end

  end #class
end #module
