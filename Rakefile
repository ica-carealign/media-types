# Rakefile for media-types

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

desc 'Cache the data from iana.org for offline use.'
task :cache do
  cp 'data/iana.json', 'data/iana_cached.json'
end

desc 'Load data from iana.org.'
task :load do
  ruby 'bin/load_data.rb'
end