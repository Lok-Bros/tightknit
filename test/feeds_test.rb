# frozen_string_literal: true

require "test_helper"
require "dotenv/load"
require "mocha/minitest"

class FeedsTest < Minitest::Test
  def setup
    skip "Skipping API integration tests in CI" if ENV["CI"]

    api_key = ENV["TIGHTKNIT_API_KEY"] || "test_api_key"
    @client = Tightknit::Client.new(api_key: api_key)
  end

  def test_list_feeds_with_vcr
    VCR.use_cassette("feeds_list") do
      result = @client.feeds.list

      assert result[:success]
      assert result[:data][:records].is_a?(Array)
    end
  end

  def test_get_feed_vcr
    VCR.use_cassette("feeds_get") do
      # Call the API to get a specific feed
      result = @client.feeds.get(ENV["TEST_FEED_ID"])

      # Verify the result
      assert result[:success]
      assert_equal ENV["TEST_FEED_ID"], result[:data][:id]
    end
  end

  def test_get_posts_vcr
    VCR.use_cassette("feeds_posts") do
      # Call the API to get posts from a feed
      result = @client.feeds.posts(ENV["TEST_FEED_ID"])

      # Verify the result
      assert result[:success]
      assert result[:data][:records].is_a?(Array)
    end
  end
end
