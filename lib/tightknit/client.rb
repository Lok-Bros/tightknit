# frozen_string_literal: true

require "faraday"
require "json"

module Tightknit
  # The Client class is the main entry point for interacting with the Tightknit API.
  # It handles the HTTP connection and provides access to the various API resources.
  #
  # @example Creating a client with global configuration
  #   Tightknit.configure do |config|
  #     config.api_key = "your_api_key"
  #   end
  #   
  #   client = Tightknit.client
  #
  # @example Creating a client with specific configuration
  #   client = Tightknit::Client.new(api_key: "your_api_key")
  #
  class Client
    # @return [Faraday::Connection] The Faraday connection object used for HTTP requests
    attr_reader :conn
    
    # Initialize a new Tightknit API client
    #
    # @param api_key [String, nil] The API key to use for authentication. If nil, uses the global configuration.
    # @param base_url [String, nil] The base URL for the API. If nil, uses the global configuration.
    # @raise [Tightknit::Error] If no API key is provided or configured
    def initialize(api_key: nil, base_url: nil)
      @api_key = api_key || Tightknit.configuration.api_key
      @base_url = base_url || Tightknit.configuration.base_url
      
      raise Error, "API key is required" unless @api_key
      
      @conn = Faraday.new(url: @base_url) do |faraday|
        faraday.headers["Authorization"] = "Bearer #{@api_key}"
        faraday.headers["Content-Type"] = "application/json"
        faraday.adapter Faraday.default_adapter
      end
    end
    
    # Access the calendar events resource
    #
    # @return [Tightknit::Resources::CalendarEvents] The calendar events resource
    def calendar_events
      @calendar_events ||= Resources::CalendarEvents.new(self)
    end
    
    # Make a GET request to the API
    #
    # @param path [String] The path to request
    # @param params [Hash] The query parameters to include
    # @return [Hash] The parsed JSON response
    # @raise [Tightknit::Error] If the request fails
    def get(path, params = {})
      handle_response(@conn.get(path, params))
    end
    
    # Make a POST request to the API
    #
    # @param path [String] The path to request
    # @param body [Hash] The request body
    # @return [Hash] The parsed JSON response
    # @raise [Tightknit::Error] If the request fails
    def post(path, body = {})
      handle_response(@conn.post(path, body.to_json))
    end
    
    # Make a PUT request to the API
    #
    # @param path [String] The path to request
    # @param body [Hash] The request body
    # @return [Hash] The parsed JSON response
    # @raise [Tightknit::Error] If the request fails
    def put(path, body = {})
      handle_response(@conn.put(path, body.to_json))
    end
    
    # Make a DELETE request to the API
    #
    # @param path [String] The path to request
    # @param params [Hash] The query parameters to include
    # @return [Hash] The parsed JSON response
    # @raise [Tightknit::Error] If the request fails
    def delete(path, params = {})
      handle_response(@conn.delete(path, params))
    end
    
    private
    
    # Handle the API response
    #
    # @param response [Faraday::Response] The Faraday response object
    # @return [Hash] The parsed JSON response
    # @raise [Tightknit::Error] If the response status is not 2xx
    def handle_response(response)
      case response.status
      when 200..299
        JSON.parse(response.body, symbolize_names: true)
      else
        error_message = begin
          error_data = JSON.parse(response.body, symbolize_names: true)
          error_data[:message] || error_data[:error] || "Unknown error"
        rescue JSON::ParserError
          response.body || "Unknown error"
        end
        
        raise Error, "API Error (#{response.status}): #{error_message}"
      end
    end
  end
end 