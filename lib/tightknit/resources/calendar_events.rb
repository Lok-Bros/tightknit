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
      
      # Create a calendar event
      #
      # @param event_data [Hash] The event data
      # @option event_data [String] :title The title of the event
      # @option event_data [String] :description The description of the event
      # @option event_data [String] :start_date The start date of the event in ISO8601 format
      # @option event_data [String] :end_date The end date of the event in ISO8601 format
      # @option event_data [String] :location_type The type of location ('virtual' or 'physical')
      # @option event_data [String] :location The location of the event
      # @option event_data [Boolean] :is_unlisted Whether the event is unlisted
      # @option event_data [String] :status The status of the event ('published', 'draft', or 'cancelled')
      # @return [Hash] Response containing the created event
      # @raise [Tightknit::Error] If the event cannot be created
      def create(event_data)
        @client.post('calendar_events', event_data)
      end
      
      # Update a calendar event
      #
      # @param event_id [String] The ID of the event to update
      # @param event_data [Hash] The updated event data
      # @return [Hash] Response containing the updated event
      # @raise [Tightknit::Error] If the event cannot be updated
      def update(event_id, event_data)
        @client.put("calendar_events/#{event_id}", event_data)
      end
      
      # Delete a calendar event
      #
      # @param event_id [String] The ID of the event to delete
      # @return [Hash] Response indicating success or failure
      # @raise [Tightknit::Error] If the event cannot be deleted
      def delete(event_id)
        @client.delete("calendar_events/#{event_id}")
      end
      
      # Format an event for display
      #
      # @param event [Hash] The event data from the API
      # @return [Hash] Formatted event data
      def format(event)
        # Extract description from Slack blocks if available
        description = ""
        if event[:description_slack_blocks] && event[:description_slack_blocks].is_a?(Array)
          event[:description_slack_blocks].each do |block|
            if block[:type] == "rich_text" && block[:elements] && block[:elements].is_a?(Array)
              block[:elements].each do |element|
                if element[:type] == "rich_text_section" && element[:elements] && element[:elements].is_a?(Array)
                  element[:elements].each do |text_element|
                    description += text_element[:text] if text_element[:text]
                  end
                end
              end
            end
          end
        end
        
        # Use plain description if Slack blocks parsing failed
        description = event[:description] if description.empty? && event[:description]
        
        # Convert Slack blocks to HTML
        description_html = Tightknit::Utils::HtmlFormatter.slack_blocks_to_html(event[:description_slack_blocks])
        
        # Get host and speaker information
        hosts = event[:hosts] || []
        speakers = event[:speakers] || []
        
        # Format the event data
        {
          id: event[:id],
          title: event[:title],
          description: description,
          description_html: description_html,
          description_slack_blocks: event[:description_slack_blocks],
          date: event[:start_date] ? Time.parse(event[:start_date]).strftime("%Y-%m-%d") : nil,
          location: event[:location] || (event[:location_type] == "virtual" ? "Virtual Event" : nil),
          image_url: event[:cover_image_url] || "https://images.unsplash.com/photo-1591115765373-5207764f72e4?q=80&w=2940&auto=format&fit=crop",
          tickets_url: event[:link] || "#",
          status: event[:status] || "upcoming",
          start_time: event[:start_date],
          end_time: event[:end_date],
          hosts: hosts.map { |h| { 
            name: h[:preferred_name] || "#{h[:first_name]} #{h[:last_name]}".strip, 
            image: h[:slack_image_72] 
          }},
          speakers: speakers.map { |s| { 
            name: s[:preferred_name] || "#{s[:first_name]} #{s[:last_name]}".strip, 
            image: s[:slack_image_72] 
          }}
        }
      end
    end
  end
end 