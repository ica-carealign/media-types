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
    # BASE_URI = 'http://www.oiramar.com/'
    
    # Base non-RFC reference URI
    BASE_NON_RFC_REF_URI = 'http://www.iana.org/assignments/media-types/media-types.xhtml#'
    
    # Base RFC reference URI
    BASE_RFC_REF_URI = 'http://www.iana.org/go/'
    
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
    def self.parse_iana_media_types(options = {})
      options = {
        :base_uri => BASE_URI,
        :types => TYPES
      }.merge(options)
      
      options[:before_parse].call() if (options.has_key?(:before_parse))
      
      parsed_data = TYPES.inject({}) do |results, type|
        uri = URI(BASE_URI + type + '.csv')
        response = Net::HTTP.get_response(uri)
        
        if (response.code == '200')
          csv_data = response.body
          csv_parse_options = {
            :headers => true
          }
        
          # "text/csv; charset=UTF-8; header=present"
          encoding = response['Content-Type'].split(/; /)[1].split(/=/)[1]
          reference_key = 'Reference'
          subtype_key = 'Name'
          results[type] = []
          
          options[:before_parse_item].call(type) if (options.has_key?(:before_parse_item))
          
          CSV.parse(csv_data, csv_parse_options) do |row|
          name = row[subtype_key].force_encoding(encoding)
          refs = row[reference_key].force_encoding(encoding).scan(/\[(.*?)\]/).map do |ref|
              ref = ref[0]
            
              if ref.match(/^RFC/)
                ref_url = BASE_RFC_REF_URI + ref.downcase
              elsif ref.match(/^http/)
                ref_url = ref
              else
                ref_url = BASE_NON_RFC_REF_URI + ref
              end
            
              {
                :name => ref,
                :url  => ref_url
              }
            end
          
            results[type] << {
              :refs    => refs,
              :subtype => extract_subtype(name),
              :remarks => extract_remarks(name)
            }
          end
          
          options[:after_parse_item].call(type) if (options.has_key?(:after_parse_item))
        else
          raise "No data to parse from #{uri}"
        end

        results[type].uniq! { |item| "#{item[:subtype]}::#{item[:remarks]}" }
  
        results
      end
      
      options[:after_parse].call() if (options.has_key?(:after_parse))
      
      parsed_data
    end

    def self.extract_subtype(text)
      /^[^\s]+/.match(text).to_s
    end

    def self.extract_remarks(text)
      /\s+[\s-]*(?<remarks>.+)$/ =~ text
      remarks
    end
  end
end