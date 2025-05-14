# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "tightknit"

require "minitest/autorun"
require "mocha/minitest"
require "vcr"
require "webmock/minitest"

# Configure VCR
VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock

  # Filter out sensitive information like API keys
  config.filter_sensitive_data("<API_KEY>") do |interaction|
    auth_header = interaction.request.headers["Authorization"]&.first
    if auth_header
      match = auth_header.match(/Bearer\s+(.+)/)
      match[1] if match
    end
  end

  # Allow localhost for CI/CD if needed
  config.ignore_localhost = true

  # Configure VCR to ignore certain hosts if needed
  # config.ignore_hosts 'example.com', 'localhost', '127.0.0.1'

  # Configure default cassette options
  config.default_cassette_options = {
    record: :once,
    match_requests_on: [:method, :uri, :body],
    allow_playback_repeats: false
  }
end

# Helper method for VCR tests
def with_vcr_cassette(name, options = {}, &block)
  VCR.use_cassette(name, options, &block)
end
