# -*- coding: utf-8 -*-
Gem::Specification.new do |spec|
  spec.name = "albatro"
  spec.version = "0.1.0"
  spec.summary = "Sentences genetate library"
  spec.description = "Sentences genetate library (markov model etc...)"
  spec.author = "akicho8"
  spec.homepage = "http://github.com/akicho8/albatro"
  spec.email = "akicho8@gmail.com"
  spec.email = "akicho8@gmail.com"
  spec.files = %x[git ls-files].scan(/\S+/)
  spec.rdoc_options = ["--line-numbers", "--inline-source", "--charset=UTF-8", "--diagram", "--image-format=jpg"]
  spec.executables = ["albatro", "morpheme"]
  spec.platform = Gem::Platform::RUBY
  spec.add_dependency "activesupport"
  spec.add_dependency "amazon-ecs"
  spec.add_dependency "google-search"
  spec.add_dependency "rspec"
  spec.add_dependency "sanitize"
  spec.add_dependency "twitter_oauth"
  spec.add_dependency "yard"
  spec.add_dependency "yard-rspec"
  spec.add_dependency "yard-rubicle"
end
