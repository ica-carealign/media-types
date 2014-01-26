# Required Gems
require 'csv'
require 'net/http'
require 'uri'

module IANA
	class MediaTypes
		##
		# Global Constants
		##
		
		# Base URI for the various media types.
		BASE_URI = 'http://www.iana.org/assignments/media-types/'
		
		# List of various registered media types.
		TYPES = ['application', 'audio', 'image', 'message', 'model', 'multipart', 'text', 'video']
		
		##
		# Public Static Methods
		##
		
		# Parse IANA media types from a specified base URI for a given set of types with the following expectations:
		#  * The expected format contains at least Name and Reference.
		#    * Name maps to the subtype
		#    * Reference represents the registering body or RFC responsible for the media type.
		#  * The file format is expected to be comma separated values (CSV).
		def self.parse_iana_media_types(base_uri = BASE_URI, types = TYPES)
			parsed_data = TYPES.inject({}) do |results, type|
				csv_data = Net::HTTP.get(URI.parse(BASE_URI + type + '.csv'))
				csv_parse_options = {
					:headers => true
				}
				encoding = 'utf-8'
				reference_key = 'Reference'
				subtype_key = 'Name'
				results[type] = []
				
				puts "Parsing CSV data for #{type}..."
				
				CSV.parse(csv_data, csv_parse_options) do |row|
					results[type] << {
						:ref     => row[reference_key].force_encoding(encoding),
						:subtype => row[subtype_key].force_encoding(encoding)
					}
				end
	
				results
			end
			
			puts 'Finished loading data from IANA.'
			
			parsed_data
		end
	end
end