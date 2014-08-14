#!/usr/bin/env ruby

# Required Gems
require 'json'
require 'fileutils'
require 'pathname'

# Required Lib
require_relative '../lib/iana/media_types'

# Global Constants
FILE_PATH = Pathname.new(File.dirname(__FILE__) + '/../data/iana.json').cleanpath

FILE_PATH.open('w') do |file|
  file.write(JSON.pretty_generate(IANA::MediaTypes.parse_iana_media_types({
    :after_parse       => -> { puts 'Finished loading data from IANA.' },
    :before_parse_item => ->(type) { puts "Parsing CSV data for #{type}..." }
  })))
end

puts "Media types data written to #{FILE_PATH}"
