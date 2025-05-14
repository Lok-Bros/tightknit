# frozen_string_literal: true

require "test_helper"
require "dotenv/load"
require "mocha/minitest"

class ClientTest < Minitest::Test
  def test_client_initialization
    client = Tightknit::Client.new(api_key: "test_api_key")
    assert_instance_of Tightknit::Client, client
  end

  def test_client_initialization_without_api_key
    assert_raises(Tightknit::Error) do
      Tightknit::Client.new(api_key: nil)
    end

    assert_raises(ArgumentError) do
      Tightknit::Client.new
    end
  end

  def test_client_resources
    client = Tightknit::Client.new(api_key: "test_api_key")

    assert_instance_of Tightknit::Resources::CalendarEvents, client.calendar_events

    assert_same client.calendar_events, client.calendar_events
  end

  def test_client_get_method
    client = Tightknit::Client.new(api_key: "test_api_key")
    conn = mock("Faraday::Connection")
    client.instance_variable_set(:@conn, conn)

    # Mock response
    mock_response = mock("Faraday::Response")
    mock_response.stubs(:status).returns(200)
    mock_response.stubs(:body).returns({success: true, data: {id: 1}}.to_json)

    # Test GET
    conn.expects(:get).with("test_path", {param: "value"}).returns(mock_response)
    result = client.get("test_path", {param: "value"})
    assert result[:success]
  end

  def test_error_handling
    client = Tightknit::Client.new(api_key: "test_api_key")
    conn = mock("Faraday::Connection")
    client.instance_variable_set(:@conn, conn)

    # Mock error response
    mock_response = mock("Faraday::Response")
    mock_response.stubs(:status).returns(404)
    mock_response.stubs(:body).returns({error: "Not found"}.to_json)

    # Test error handling
    conn.expects(:get).with("test_path", {}).returns(mock_response)
    assert_raises(Tightknit::Error) do
      client.get("test_path")
    end

    # Test network error handling
    conn.expects(:get).with("test_path", {}).raises(Faraday::ConnectionFailed.new("Connection failed"))
    assert_raises(Tightknit::Error) do
      client.get("test_path")
    end
  end
end
