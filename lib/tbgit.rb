require "tbgit/version"
require "tempfile"

module Main

  class TBGit

  	def spacer
  		puts "********************************************************************************"
  	end

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

    def add_remote_all
    	students = IO.readlines(@students_file)

		puts "Adding students' repositories to remote 'all', to facilitate `git push all master`"
		puts "Manually adding the following to .git/config, in order to create remote 'all':"
		open('.git/config', 'a') { |f|
			f.puts '[remote "all"]'
			puts '[remote "all"]'

		students.each do |username|
			username.delete!("\n")
			str =  "\turl = https://github.com/"+@organization+"/" + username + "-"+@reponame+".git"
			puts str
			f.puts str
		end

		}

    end

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

	def git_update
		puts "git remote update"
 		system "git remote update"
 	end

 	def create_local_tracking_remotes
 	    students = IO.readlines(@students_file)
 		students.each do |username|
			username.delete!("\n")

			puts "Creating Local Branch to Track Remote: " + username 
			checkout_command = "git checkout -b " + username + " remotes/" + username + "/master"
			puts checkout_command
			system  checkout_command

		end

	end

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
  
  	# def git_push_all
  	# 	git_branch

  	# 	puts "\nPush current branch to all student repositories? (y/n)"
  	# 	yn = $stdin.gets.chomp
  	# 	if yn== 'y'
  	# 		puts "git push all master"
  	# 		system "git push all master"
  	# 	end
  	# end

  	def all_remotes_list
  		remote_file = Tempfile.new("remotes")
  		system "git remote >> " + remote_file.path

  		puts "git remote >> " + remote_file.path

  		return IO.readlines(remote_file)
	end

  	def update_repos(pushpull)
  		all_remotes = all_remotes_list
  		all_remotes.each do |branch|
  			branch.delete!("\n")

  			if (branch != "all")&&(branch != "origin")
	  			checkout_command = "git checkout " + branch 
	  			pushpull_command = "git " + pushpull + " " + branch + " master"

	  			puts checkout_command
	  			system checkout_command

	  			puts pushpull_command
	  			system pushpull_command
	  		end

	  		switch_to_master

  		end

  	end

  	def commit_all

  		puts "Commit Message: "
  		message = $stdin.gets.chomp

  		all_remotes = all_remotes_list

  		all_remotes.each do |branch|
  			branch.delete!("\n")

  			if (branch != "all")&&(branch != "origin")
	  			checkout_command = "git checkout " + branch 
	  			stage_changes = "git add --all"
	  			commit_command = "git commit -am '" + message + "'"

	  			puts checkout_command
	  			system checkout_command

	  			puts stage_changes
	  			system stage_changes

	  			puts commit_command
	  			system commit_command
	  		end

  		end
	  		switch_to_master

  	end

  	def merge_from

  		puts "Merge from branch: "
  		merge_branch = $stdin.gets.chomp

  		all_remotes = all_remotes_list
  		all_remotes.each do |branch|
  			branch.delete!("\n")

  			if (branch != "all")&&(branch != "origin")
	  			checkout_command = "git checkout " + branch 
	  			merge_command = "git merge " + merge_branch.to_s

	  			puts checkout_command
	  			system checkout_command

	  			puts merge_command
	  			system merge_command
	  		end

	  		switch_to_master

  		end

  	end

  end #class
end #module
