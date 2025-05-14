# frozen_string_literal: true

require "faraday"
require "json"

module Tightknit
  # The Client class is the main entry point for interacting with the Tightknit API.
  # It handles the HTTP connection and provides access to the various API resources.
  #
  # @example Creating a client
  #   client = Tightknit::Client.new(api_key: "your_api_key")
  #
  class Client
    # @return [Faraday::Connection] The Faraday connection object used for HTTP requests
    attr_reader :conn

    # Initialize a new Tightknit API client
    #
    # @param api_key [String] The API key to use for authentication
    # @raise [Tightknit::Error] If no API key is provided
    def initialize(api_key:)
      @api_key = api_key

      raise Error, "API key is required" unless @api_key

      @conn = Faraday.new(url: BASE_URL) do |faraday|
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

    # Access the feeds resource
    #
    # @return [Tightknit::Resources::Feeds] The feeds resource
    def feeds
      @feeds ||= Resources::Feeds.new(self)
    end

    # Make a GET request to the API
    #
    # @param path [String] The path to request
    # @param params [Hash] The query parameters to include
    # @return [Hash] The parsed JSON response
    # @raise [Tightknit::Error] If the request fails
    def get(path, params = {})
      response = @conn.get(path, params)
      handle_response(response)
    rescue Faraday::Error => e
      handle_error(e)
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

    # Handle Faraday errors
    #
    # @param error [Faraday::Error] The Faraday error
    # @raise [Tightknit::Error] A wrapped error with more context
    def handle_error(error)
      raise Error, "Network Error: #{error.message}"
    end
  end
end
