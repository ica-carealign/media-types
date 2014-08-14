require 'erubis'
require 'json'
require 'facets/string/titlecase'
require 'pathname'
require 'fileutils'

module ERuby
  class Generator
    def self.generate_dotnet(input_file, output_directory, version)
      output_files = []
      eruby = load_template('MediaTypeClass.ercs')
      input = JSON.parse(File.read(input_file))

      models = input.map do |key, value|
        {
          :name => dotnet_typename(key),
          :value => key,
          :content => value
        }
      end

      models.each do |model|
        output_file_name = model[:name] + '.cs'
        output_file = "#{output_directory}/#{output_file_name}"
        subTypes = dotnet_subtypes(model[:content])
        duplicates = subTypes.group_by{ |item| item[:name] }.select{ |k,v| v.size > 1 }.keys
        duplicates.each do |dupe|
          matches = subTypes.select{ |type| type[:name] == dupe }
          matches.each_with_index{ |item,index| item[:name] << (index + 1).to_s }
        end
        File.open(output_file, 'w') do |file|
          file.write(eruby.evaluate({
            :typeValue => model[:value],
            :typeName => model[:name],
            :subTypes => subTypes
          }))
        end
        output_files << output_file_name
      end
      
      properties_folder = "#{output_directory}/Properties"
      unless File.directory? properties_folder
        FileUtils.mkdir_p properties_folder
      end
      info_file = "#{properties_folder}/AssemblyInfo.cs"
      File.open(info_file, 'w'){ |file| file.write(load_evaluate_template('AssemblyInfo.ercs', {:version => version})) }

      proj_file = output_directory.to_s + '/Iana.MediaTypes.csproj'
      File.open(proj_file, 'w') do |file|
        file.write(load_evaluate_template('Iana.MediaTypes.ercsproj', {
          :files => output_files
        }))
      end
    end

    def self.dotnet_subtypes(subTypes)
      result = []
      subTypes.each do |subType|
        result << {
          :name => dotnet_typename(subType['subtype']),
          :value => subType['subtype'],
          :remarks => dotnet_remarks(subType)
        }
      end
      result
    end

    def self.dotnet_typename(name)
      name.downcase.gsub(/[^0-9a-z]/, ' ')
        .titlecase.gsub(/\s+/, '')
        .gsub(/^(\d{1})/, '_\1')
    end

    def self.dotnet_remarks(subType)
      if /(deprecated)|(obsolete)/i.match(subType['remarks'])
        load_evaluate_template('SubTypeObsolete.ercs', subType)
      elsif !subType['remarks'].to_s.empty?
        load_evaluate_template('SubTypeRemarks.ercs', subType)
      else
        nil
      end
    end

    def self.load_evaluate_template(template_name, context)      
      eruby = load_template(template_name)
      eruby.evaluate(context)
    end

    def self.load_template(template_name)  
      template = File.read(File.dirname(__FILE__) + '/' + template_name)
      Erubis::Eruby.new(template)
    end
  end
end