# frozen_string_literal: true

require "test_helper"

class TightknitTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Tightknit::VERSION
  end
  
  def test_base_url_constant
    assert_equal "https://api.tightknit.dev/admin/v0/", Tightknit::BASE_URL
  end
  
  def test_client_initialization
    client = Tightknit::Client.new(api_key: "test_api_key")
    assert_instance_of Tightknit::Client, client
    assert_equal "test_api_key", client.instance_variable_get(:@api_key)
  end
  
  def test_client_initialization_without_api_key
    assert_raises(Tightknit::Error) do
      Tightknit::Client.new(api_key: nil)
    end
    
    assert_raises(ArgumentError) do
      Tightknit::Client.new
    end
  end
end 