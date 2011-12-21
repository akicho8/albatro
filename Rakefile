require "bundler"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new
task :default => :spec
task :test => :spec

require "rake/clean"
CLEAN << "pkg" << ".yardoc" << "doc" << "log" << "tmp"

require "yard"
YARD::Rake::YardocTask.new
