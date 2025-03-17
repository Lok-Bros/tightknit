# frozen_string_literal: true

require_relative "tightknit/version"
require_relative "tightknit/client"
require_relative "tightknit/resources/calendar_events"
require_relative "tightknit/utils/html_formatter"

# The Tightknit module is the main namespace for the Tightknit API client.
# It provides configuration options and a convenient way to access the API client.
#
# @example Configure the client globally
#   Tightknit.configure do |config|
#     config.api_key = "your_api_key"
#   end
#
# @example Access the client
#   client = Tightknit.client
#   events = client.calendar_events.list
#
module Tightknit
  # Error class for Tightknit-specific exceptions
  class Error < StandardError; end
  
  # Configuration class for Tightknit
  # Holds the API key and base URL for the API
  #
  # @attr_accessor [String] api_key The API key for authentication
  # @attr_accessor [String] base_url The base URL for the API
  class Configuration
    attr_accessor :api_key, :base_url
    
    # Initialize a new Configuration object with default values
    def initialize
      @base_url = "https://api.tightknit.dev/admin/v0/"
    end
  end
  
  class << self
    attr_writer :configuration
    
    # Get the current configuration
    # Creates a new configuration if one doesn't exist
    #
    # @return [Tightknit::Configuration] The current configuration
    def configuration
      @configuration ||= Configuration.new
    end
    
    # Configure the Tightknit client
    # Yields the current configuration for modification
    #
    # @yield [config] The current configuration
    # @yieldparam config [Tightknit::Configuration] The configuration to modify
    # @return [Tightknit::Configuration] The modified configuration
    def configure
      yield(configuration)
    end
    
    # Get the Tightknit client
    # Creates a new client if one doesn't exist
    #
    # @return [Tightknit::Client] The Tightknit client
    def client
      @client ||= Client.new
    end
  end
end
