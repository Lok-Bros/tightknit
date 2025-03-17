# frozen_string_literal: true

require "test_helper"
require "dotenv/load"
require "mocha/minitest"
require "time"

class TightknitTest < Minitest::Test
  def setup
    # Configure the client with the API key from environment variables
    Tightknit.configure do |config|
      config.api_key = ENV["TIGHTKNIT_API_KEY"] || "test_api_key"
    end
    
    # Create a client with a mocked connection
    @client = Tightknit::Client.new(api_key: "test_api_key")
    @conn = mock("Faraday::Connection")
    @client.instance_variable_set(:@conn, @conn)
  end
  
  def test_that_it_has_a_version_number
    refute_nil ::Tightknit::VERSION
  end
  
  def test_list_events
    # Mock data
    mock_events = {
      success: true,
      data: {
        records: [
          {
            id: "event1",
            title: "Test Event 1",
            description: "Test Description 1",
            start_date: Time.now.iso8601,
            end_date: (Time.now + 60*60*2).iso8601
          },
          {
            id: "event2",
            title: "Test Event 2",
            description: "Test Description 2",
            start_date: (Time.now + 60*60*24).iso8601,
            end_date: (Time.now + 60*60*24 + 60*60*2).iso8601
          }
        ],
        total: 2
      }
    }
    
    # Mock response
    mock_response = mock("Faraday::Response")
    mock_response.stubs(:status).returns(200)
    mock_response.stubs(:body).returns(mock_events.to_json)
    
    # Set expectations
    @conn.expects(:get)
         .with("calendar_events", {page: 0, per_page: 10, status: "published"})
         .returns(mock_response)
    
    # Call the method
    result = @client.calendar_events.list
    
    # Verify the result
    assert result[:success]
    assert_equal 2, result[:data][:records].length
    assert_equal "Test Event 1", result[:data][:records][0][:title]
  end
  
  def test_get_event
    # Mock data
    mock_event = {
      success: true,
      data: {
        id: "event1",
        title: "Test Event 1",
        description: "Test Description 1",
        start_date: Time.now.iso8601,
        end_date: (Time.now + 60*60*2).iso8601
      }
    }
    
    # Mock response
    mock_response = mock("Faraday::Response")
    mock_response.stubs(:status).returns(200)
    mock_response.stubs(:body).returns(mock_event.to_json)
    
    # Set expectations
    @conn.expects(:get)
         .with("calendar_events/event1")
         .returns(mock_response)
    
    # Call the method
    result = @client.calendar_events.get("event1")
    
    # Verify the result
    assert result[:success]
    assert_equal "Test Event 1", result[:data][:title]
  end
  
  def test_create_event
    # Mock data
    event_data = {
      title: "New Event",
      description: "New Event Description",
      start_date: Time.now.iso8601,
      end_date: (Time.now + 60*60*2).iso8601,
      location_type: "virtual",
      location: "Virtual",
      is_unlisted: false,
      status: "published"
    }
    
    mock_response_data = {
      success: true,
      data: event_data.merge(id: "new_event_id")
    }
    
    # Mock response
    mock_response = mock("Faraday::Response")
    mock_response.stubs(:status).returns(200)
    mock_response.stubs(:body).returns(mock_response_data.to_json)
    
    # Set expectations
    @conn.expects(:post)
         .with("calendar_events", event_data.to_json)
         .returns(mock_response)
    
    # Call the method
    result = @client.calendar_events.create(event_data)
    
    # Verify the result
    assert result[:success]
    assert_equal "New Event", result[:data][:title]
    assert_equal "new_event_id", result[:data][:id]
  end
  
  def test_error_handling
    # Mock response with error
    mock_response = mock("Faraday::Response")
    mock_response.stubs(:status).returns(404)
    mock_response.stubs(:body).returns({error: "Event not found"}.to_json)
    
    # Set expectations
    @conn.expects(:get)
         .with("calendar_events/nonexistent")
         .returns(mock_response)
    
    # Call the method and expect an error
    assert_raises(Tightknit::Error) do
      @client.calendar_events.get("nonexistent")
    end
  end
end 