# frozen_string_literal: true

require "time"

module Tightknit
  module Resources
    # The CalendarEvents class provides methods for interacting with the calendar events API.
    # It allows listing, creating, updating, and deleting calendar events.
    #
    # @example List upcoming events
    #   client = Tightknit.client
    #   events = client.calendar_events.list(time_filter: "upcoming")
    #
    # @example Get a specific event
    #   client = Tightknit.client
    #   event = client.calendar_events.get("event_id")
    #
    class CalendarEvents
      # Initialize a new CalendarEvents resource
      #
      # @param client [Tightknit::Client] The client to use for API requests
      def initialize(client)
        @client = client
      end
      
      # Get a list of calendar events
      #
      # @param options [Hash] Options for filtering events
      # @option options [Integer] :page (0) Page number
      # @option options [Integer] :per_page (10) Number of records per page
      # @option options [String] :time_filter ('upcoming' or 'past') Filter events by time
      # @option options [String] :status ('published') Filter events by status
      # @return [Hash] Response containing events data
      def list(options = {})
        page = options[:page] || 0
        per_page = options[:per_page] || 10
        time_filter = options[:time_filter]
        status = options[:status] || 'published'
        
        params = {
          page: page,
          per_page: per_page,
          status: status
        }
        
        # Only add time_filter to params if it's specified
        params[:time_filter] = time_filter if time_filter
        
        @client.get('calendar_events', params)
      end
      
      # Get both past and upcoming events
      #
      # @param options [Hash] Options for filtering events
      # @option options [Integer] :page (0) Page number
      # @option options [Integer] :per_page (10) Number of records per page
      # @option options [String] :status ('published') Filter events by status
      # @return [Hash] Combined response containing both past and upcoming events
      def all(options = {})
        # Get upcoming events
        upcoming_options = options.dup
        upcoming_options[:time_filter] = 'upcoming'
        upcoming_response = list(upcoming_options)
        
        # Get past events
        past_options = options.dup
        past_options[:time_filter] = 'past'
        past_response = list(past_options)
        
        # Combine the results
        if upcoming_response[:success] && past_response[:success]
          combined_records = []
          
          if upcoming_response[:data] && upcoming_response[:data][:records]
            combined_records += upcoming_response[:data][:records]
          end
          
          if past_response[:data] && past_response[:data][:records]
            combined_records += past_response[:data][:records]
          end
          
          # Create a combined response with the same structure
          {
            success: true,
            data: {
              records: combined_records,
              total: combined_records.length
            }
          }
        else
          # If either request failed, return the successful one or the first error
          upcoming_response[:success] ? upcoming_response : past_response
        end
      end
      
      # Get a specific calendar event
      #
      # @param event_id [String] The ID of the event to retrieve
      # @return [Hash] Response containing event data
      # @raise [Tightknit::Error] If the event is not found or another error occurs
      def get(event_id)
        @client.get("calendar_events/#{event_id}")
      end
      
      # Format event data for the API
      #
      # @param event_data [Hash] The raw event data
      # @return [Hash] The formatted event data
      # @private
      def format_data(event_data)
        # Create a new hash to avoid modifying the original
        formatted = event_data.dup
        
        # Format description if it's a string
        if formatted[:description].is_a?(String)
          formatted[:description] = { text: formatted[:description] }
        end
        
        # Format recap if it's a string
        if formatted[:recap].is_a?(String)
          formatted[:recap] = { text: formatted[:recap] }
        end
        
        # Format hosts if it's an array of IDs
        if formatted[:hosts].is_a?(Array)
          formatted[:hosts] = { slack_user_ids: formatted[:hosts] }
        end
        
        # Format speakers if it's an array of IDs
        if formatted[:speakers].is_a?(Array)
          formatted[:speakers] = { slack_user_ids: formatted[:speakers] }
        end
        
        formatted
      end      
    end
  end
end 