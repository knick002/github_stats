require 'rest_client'
require 'JSON'
require 'benchmark'
require_relative '../config/setup_helper.rb'

module TestAPI
    
    class Base
            attr_accessor   :resource,
                            :response,
                            :result,
                            :measured_time,
                            :this_request,
                            :user_id
                            :cookie
                            :no_sign_in
            @@RESULT_FILE = get_result_file
            
	
        def initialize
            read_config
            sign_in unless @no_sign_in
        end
	
        def create_resource(cookie = nil)
            @resource = RestClient::Resource.new(@base_url,  headers: @mime)
        end

        def execute_request(method, req_url, data=nil, expected_code=200)

            begin
                @this_method = caller_locations(1,1)[0].label # for Ruby2.0
                #@this_method = caller[0][/`.*'/][1..-2] # for Ruby 1.9
                create_resource
                @response, @result = nil
                @this_request = @base_url + req_url
                @expected_code = expected_code
                @measured_time = Benchmark.realtime {
                                    case method
                                    when 'get'
                                        @response = @resource[req_url].get
                                    when 'post'
                                        @response = @resource[req_url].post data.to_json
                                    when 'put'
                                        @response = @resource[req_url].put data.to_json
                                    when 'delete'
                                        @response = @resource[req_url].delete
                                    when 'postfile'
                                        @response = @resource[req_url].post data
                                    else
                                        puts "Given method #{method} not defined for #{req_url}"
                                    end
                                }
                @result = JSON.parse(@response.body)
                @measured_time = (@measured_time * 1000).round
                print_response(data)
            rescue Exception => e
                @error = e
                print_response
            end
            
        end

        
        def sign_in
        
        end
        
        
        def get_user_id
            
        end

        def print_response(data=nil)
            @result_code = (@response.nil?) ? @error.message.scan(/^\d+/)[0].to_i : @response.code
            @result ||= @error.response
            text = "Here is API Test results:"
            text += "\nMethod: #{@this_method}\nUrl: #{@this_request}\nResCode: #{@result_code}\nResult: #{@result}\nTimeTaken: #{@measured_time} ms"
            append_to_file(text, @@RESULT_FILE)
        end
        
    end

end
