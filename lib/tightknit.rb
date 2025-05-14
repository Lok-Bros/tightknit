# frozen_string_literal: true

require_relative "tightknit/version"
require_relative "tightknit/client"
require_relative "tightknit/resources/calendar_events"
require_relative "tightknit/resources/feeds"
require_relative "tightknit/utils/html_formatter"

# The Tightknit module is the main namespace for the Tightknit API client.
# It provides a simple way to interact with the Tightknit API.
#
# @example Create a client
#   client = Tightknit::Client.new(api_key: "your_api_key")
#   events = client.calendar_events.list
#
module Tightknit
  # Error class for Tightknit-specific exceptions
  class Error < StandardError; end

  # Base URL for the Tightknit API
  BASE_URL = "https://api.tightknit.dev/admin/v0/"
end
