#!/usr/bin/env ruby

# Required Gems
require 'json'
require 'pathname'

# Required Lib
require_relative '../lib/IANA/MediaTypes'

# Global Constants
FILE_LOCATION = Pathname.new(File.dirname(__FILE__) + '/../data/iana.json').realpath

File.open(FILE_LOCATION, 'w') do |file|
	file.write(JSON.pretty_generate(IANA::MediaTypes.parse_iana_media_types()))
end

puts "Media types data written to #{FILE_LOCATION}"