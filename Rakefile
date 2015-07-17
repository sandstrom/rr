require 'rubygems'
require 'bundler'
require 'rake'

require 'pp'

# appraisal
require 'appraisal'

# build, install, release
require 'bundler/gem_tasks'

# appraisals
Appraisal::File.each do |appraisal|
  desc "Resolve and install dependencies for the #{appraisal.name} appraisal"
  task "appraisal:#{appraisal.name}:install" do
    appraisal.install
  end
end

# spec
require File.expand_path('../spec/defines_spec_suite_tasks', __FILE__)
DefinesSpecSuiteTasks.call

desc "Run tests"
task :test do
  ruby("test/run-test.rb")
end

task :default => ['appraisal:install', :spec, :test]
