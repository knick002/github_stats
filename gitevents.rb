require 'date'
require_relative './testapi/base.rb'

class GitEvents < TestAPI::Base
    
    def initialize
        @options = options_parser
    	@no_sign_in = true
        super
        @@base_request =  "/events"
    end
    
    def get_events
        request = "?q=&per_page=200" # Add extra params here
        data_hash = {}
        execute_request('get', @@base_request + request, data_hash)
        puts "API request returned #{@result.count} records"
        process_result
    end

    def process_result
        #start_date = '2016-01-01T13:00:00Z'
        #end_date = '2016-11-02T13:00:00Z'
        #event_type = "PushEvent"
        #count = 2
        start_date = @options[:after]
        end_date = @options[:before]
        count = @options[:count]
        event_type = @options[:type]
        repo_stats = Hash.new(0)
        @result.each do |item|
            # check if created_at matches with given date range
            # check if event_type matches given event type
            created_at = item['created_at']
            if check_date_in_range(start_date, end_date, created_at) && item['type'] == event_type
                repo_name = item['repo']['name']
                repo_stats[repo_name] = repo_stats[repo_name] + 1
            end
        end
        print_output(repo_stats, count)
    end

    def check_date_in_range(start_date, end_date, created_at)
		created_at = get_dt_object(created_at)
		return (start_date..end_date).cover? created_at
	end

	def get_dt_object(dt)
		# DateTime.strptime('2012-10-01T13:00:00Z','%FT%TZ')
		return DateTime.strptime(dt,'%FT%TZ')
	end

    
    def print_output(repo_stats, count)
        sort_desc = repo_stats.sort_by { |k, v| v }.reverse
        for i in 1..count do 
            repo_name = sort_desc[i][0]
            count = sort_desc[i][1]
            puts "\n#{repo_name} - #{count} events" 
        end      
    end

end
	 
stats = GitEvents.new
stats.get_events
