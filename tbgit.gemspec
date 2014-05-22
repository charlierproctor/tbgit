# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tbgit/version'

Gem::Specification.new do |spec|
  spec.name          = "tbgit"
  spec.version       = Tbgit::VERSION
  spec.authors       = ["Charlie Proctor"]
  spec.email         = ["charlie@charlieproctor.com"]
  spec.summary       = %q{TBGit is a command-line utility to facilitate the management of multiple GitHub student repositories.}
  spec.description   = %q{
  Commands:
    ~ setup     sets up a tbgit environment. See decription below
    ~ push    pushes all local student branches to their remote master branches
    ~ pull    pulls all remote master branches to local student branches
    ~ merge     merges a specified branch with each student branch and then commits the changes

    ~ add-remotes   adds each student's repository as a remote
    ~ create-locals   creates a local branch to track the students remote master branch
      ^----> these are both part of the setup process

  TBGit Environment
    ~ it's a regular git repository -- with lots of fancy features!
    ~ there is a master branch for teachers to work off of (create hw files, etc..)
        --> teachers can obviously create and work off other branches if desired
    ~ each student's repository is a remote of the git repo
    ~ there is a local branch to track each student's remote master branches

  Setup
    1. Teachers create the student repositories (https://github.com/education/teachers_pet works perfectly well for this)
        --> initialize these repos with a README or push out a starter file.
    2. Teachers create a repo for themselves. This will serve as the base for the tbgit environment.
    3. Change to that repo's directory, execute `tbgit setup`, and follow the instructions.

  A Typical Workflow
    1. Teachers create the assignment (on the master branch) and make a final commit when they're ready to deploy it
    2. Teachers pull all the students' repos to make sure they're up to date.
        --> `tbgit pull`
    3. Teachers merge their master branch with each student's local branch
        --> `tbgit merge`
    4. At this point, teachers should check to make sure their were no merge conflicts. If there were, go in and fix them.
        --> feel free to `git checkout <username>` a few different branches
    4. Teachers push each students local branch to the student's remote master branch
        --> `tbgit push`
    5. Make sure it worked.  Do a victory lap.

    To view student solutions at any point, just `tbgit pull` and `git checkout <username>`

}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ["tbgit"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
