# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tbgit/version'

Gem::Specification.new do |spec|
  spec.name          = "tbgit"
  spec.version       = Tbgit::VERSION
  spec.authors       = ["Charlie Proctor"]
  spec.email         = ["charlie@charlieproctor.com"]
  spec.summary       = %q{YEI TB Git Commands}
  spec.description   = %q{more description}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ["tbgit"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
