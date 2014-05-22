require "tbgit/version"
require "tempfile"

module Main

  class TBGit

  	def spacer
  		puts "********************************************************************************"
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
  	def update_repos(pushpull)
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

  		confirm("This performs a merge and commit on each local student branch. You will be prompted for the branch to merge from (normally master). Would you like to continue?")
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
