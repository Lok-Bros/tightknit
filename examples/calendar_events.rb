#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "tightknit"
require "dotenv/load"
require "time"

# Configure the client with the API key from environment variables
Tightknit.configure do |config|
  config.api_key = ENV["TIGHTKNIT_API_KEY"]
end

# Get upcoming events
puts "Fetching upcoming events..."
upcoming_events = Tightknit.client.calendar_events.list(time_filter: "upcoming")

if upcoming_events[:success]
  puts "Found #{upcoming_events[:data][:total]} upcoming events:"
  upcoming_events[:data][:records].each do |event|
    formatted_event = Tightknit.client.calendar_events.format(event)
    puts "- #{formatted_event[:title]} (#{formatted_event[:date]})"
  end
else
  puts "Error fetching upcoming events: #{upcoming_events[:error]}"
end

puts "\n"

# Get past events
puts "Fetching past events..."
past_events = Tightknit.client.calendar_events.list(time_filter: "past")

if past_events[:success]
  puts "Found #{past_events[:data][:total]} past events:"
  past_events[:data][:records].each do |event|
    formatted_event = Tightknit.client.calendar_events.format(event)
    puts "- #{formatted_event[:title]} (#{formatted_event[:date]})"
  end
else
  puts "Error fetching past events: #{past_events[:error]}"
end

puts "\n"

# Get all events (both past and upcoming)
puts "Fetching all events..."
all_events = Tightknit.client.calendar_events.all

if all_events[:success]
  puts "Found #{all_events[:data][:total]} total events:"
  all_events[:data][:records].each do |event|
    formatted_event = Tightknit.client.calendar_events.format(event)
    puts "- #{formatted_event[:title]} (#{formatted_event[:date]})"
  end
else
  puts "Error fetching all events: #{all_events[:error]}"
end

# Uncomment to create a new event
# puts "\nCreating a new event..."
# event_data = {
#   title: "API Client Test Event",
#   description: "This event was created using the Tightknit API client gem.",
#   start_date: (Time.now + 60*60*24*7).iso8601, # 1 week from now
#   end_date: (Time.now + 60*60*24*7 + 60*60*2).iso8601, # 2 hours duration
#   location_type: "virtual",
#   location: "Virtual",
#   is_unlisted: false,
#   status: "published"
# }
# 
# result = Tightknit.client.calendar_events.create(event_data)
# 
# if result[:success]
#   puts "Event created successfully with ID: #{result[:data][:id]}"
# else
#   puts "Error creating event: #{result[:error]}"
# end 