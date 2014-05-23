class HelpText
  	def helpme
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
end