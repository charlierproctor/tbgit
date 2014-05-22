
 	
  	def commit_all

  		confirm("This will commit changes on all local student branches -- continue?")

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


  	def git_push_all
  		git_branch

  		puts "\nPush current branch to all student repositories? (y/n)"
  		yn = $stdin.gets.chomp
  		if yn== 'y'
  			puts "git push all master"
  			system "git push all master"
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