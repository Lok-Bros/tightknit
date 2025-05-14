# frozen_string_literal: true

module Tightknit
  # The Resources module contains classes for interacting with different API resources.
  module Resources
    # The Feeds class provides methods for interacting with the feeds API.
    # It allows listing feeds and retrieving posts from feeds.
    #
    # @example List feeds
    #   client = Tightknit.client
    #   feeds = client.feeds.list
    #
    # @example Get a specific feed
    #   client = Tightknit.client
    #   feed = client.feeds.get("feed_id")
    #
    # @example Get posts from a feed
    #   client = Tightknit.client
    #   posts = client.feeds.posts("feed_id")
    #
    class Feeds
      # Initialize a new Feeds resource
      #
      # @param client [Tightknit::Client] The client to use for API requests
      def initialize(client)
        @client = client
      end

      # Get a list of feeds in the community
      #
      # @param options [Hash] Options for pagination
      # @option options [Integer] :page (0) Page number
      # @option options [Integer] :per_page (10) Number of records per page
      # @return [Hash] Response containing feeds data
      def list(options = {})
        page = options[:page] || 0
        per_page = options[:per_page] || 10

        params = {
          page: page,
          per_page: per_page
        }

        @client.get("feeds", params)
      end

      # Get a specific feed
      #
      # @param feed_id [String] The ID of the feed to retrieve
      # @return [Hash] Response containing feed data
      # @raise [Tightknit::Error] If the feed is not found or another error occurs
      def get(feed_id)
        @client.get("feeds/#{feed_id}")
      end

      # Get posts from a specific feed
      #
      # @param feed_id [String] The ID of the feed to retrieve posts from
      # @param options [Hash] Options for pagination
      # @option options [Integer] :page (0) Page number
      # @option options [Integer] :per_page (10) Number of records per page
      # @return [Hash] Response containing posts data
      # @raise [Tightknit::Error] If the feed is not found or another error occurs
      def posts(feed_id, options = {})
        page = options[:page] || 0
        per_page = options[:per_page] || 10

        params = {
          page: page,
          per_page: per_page
        }

        @client.get("feeds/#{feed_id}/posts", params)
      end
    end
  end
end
