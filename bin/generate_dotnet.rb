#!/usr/bin/env ruby

require 'pathname'
require 'fileutils'

require_relative '../lib/ERuby/Generator'

thisDir = File.dirname(__FILE__)
input_file = Pathname.new(thisDir + '/../data/iana_cached.json').realpath
output_directory = Pathname.new(thisDir + '/../src/dotnet/Iana.MediaTypes').realdirpath
version_file = Pathname.new(thisDir + '/../VERSION').realpath
FileUtils::mkdir_p output_directory

ERuby::Generator.generate_dotnet(input_file, output_directory, IO.read(version_file))