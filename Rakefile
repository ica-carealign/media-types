# Rakefile for media-types

require 'rake/clean'

##
# Directories and files to clean
##
CLEAN.include('data/iana.json')
CLEAN.include('src')

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

desc 'Load data from iana.org, cache it, and generate output for all supported platforms.'
task :generate_fresh => [:load, :cache, :generate]

desc 'Generate output for all supported platforms.'
task :generate => [:generate_dotnet]

desc 'Generate a .NET assembly using cached data from iana.org.'
task :generate_dotnet do
  ruby 'bin/generate_dotnet.rb'
end