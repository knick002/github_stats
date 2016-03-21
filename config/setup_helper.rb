require 'yaml'
require 'optparse'
require 'optparse/date'
# Define test environment

def get_result_file
    return "API_results_#{get_date}.txt"
end

def read_config
    conf = YAML.load_file("config/config.yaml")
    conf.each{|k,v| instance_variable_set("@#{k}", v)}
end

def get_date
    return Time.now.strftime("%m%d%Y") 
end


def append_to_file(text, file)
	File.new(file, 'a') unless File.exists?(file)
	File.open(file, 'a') { |f|
		f << "\n\n===#{Time.now}==="
        	f << "\n#{text}"
		}
end

def options_parser
    options = {}
    OptionParser.new do|opts|
        opts.banner = "Usage: [options]"
        opts.on('-n', '--count N', Integer, 'Count') do |x|
                options[:count] = x
        end

        opts.on('-a', '--after [DateTime]', DateTime, 'After') do |x|
                options[:after] = x
        end

        opts.on('-b', '--before [DateTime]', DateTime, 'Before') do |x|
                options[:before] = x
        end

        opts.on('-e', '--event [Event_Name]', String, 'Event_Type') do |x|
                options[:type] = x
        end

        opts.on('-h', '--help', 'Display Help') do
                puts opts
                exit
        end
    end.parse!
    return options
end



