# Rakefile for media-types

# Required Gems
require 'rake/clean'

##
# Directories and files to clean
##
CLEAN.include('data/iana.json')

##
# Tasks
##
desc 'Load and build media types for a target language/platform.'
task :default => [:load]

desc 'Cache the data from iana.org.'
task :cache do
	sh 'cp data/iana.json data/iana_cached.json'
end

desc 'Load data from iana.org.'
task :load do
	ruby 'bin/load_data.rb'
end