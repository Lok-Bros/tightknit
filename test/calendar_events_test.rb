# frozen_string_literal: true

require "test_helper"
require "dotenv/load"
require "mocha/minitest"
require "time"

class CalendarEventsTest < Minitest::Test
  def setup
    skip "Skipping API integration tests in CI" if ENV["CI"]
    
    api_key = ENV["TIGHTKNIT_API_KEY"] || "test_api_key"
    @client = Tightknit::Client.new(api_key: api_key)
  end
  
  def test_list_events_with_vcr
    VCR.use_cassette("calendar_events_list") do
      result = @client.calendar_events.list
      
      assert result[:success]
      assert result[:data][:records].is_a?(Array)
    end
  end
  
  def test_list_events_with_time_filter_vcr
    VCR.use_cassette("calendar_events_list_upcoming") do
      # Call the API with time_filter
      result = @client.calendar_events.list(time_filter: "upcoming")
      
      # Verify the result
      assert result[:success]
      assert result[:data][:records].is_a?(Array)
    end
  end
  
  def test_get_event_vcr   
    VCR.use_cassette("calendar_events_get") do
      # Call the API to get a specific event
      result = @client.calendar_events.get(ENV["TEST_EVENT_ID"])
      
      # Verify the result
      assert result[:success]
      assert_equal ENV["TEST_EVENT_ID"], result[:data][:id]
    end
  end
end 