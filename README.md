# Tightknit

A Ruby client for the Tightknit API.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add tightknit
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install tightknit
```

## Usage

### Configuration

Configure the Tightknit client with your API key:

```ruby
require 'tightknit'

# Configure globally
Tightknit.configure do |config|
  config.api_key = 'your_api_key'
  # Optional: override the base URL if needed
  # config.base_url = 'https://api.tightknit.dev/admin/v0/'
end

# Or create a client instance with specific configuration
client = Tightknit::Client.new(api_key: 'your_api_key')
```

### Calendar Events

#### List Events

```ruby
# Get events with default parameters (page 0, per_page 10, status 'published')
events = Tightknit.client.calendar_events.list

# With custom parameters
events = Tightknit.client.calendar_events.list(
  page: 1,
  per_page: 20,
  time_filter: 'upcoming',
  status: 'published'
)

# Available time_filter values: 'upcoming', 'past'
# Available status values: 'published', 'draft', 'cancelled'
```

#### Get All Events (Both Past and Upcoming)

```ruby
all_events = Tightknit.client.calendar_events.all(
  page: 0,
  per_page: 10,
  status: 'published'
)
```

#### Get a Specific Event

```ruby
event = Tightknit.client.calendar_events.get('event_id')
```

#### Create an Event

```ruby
event_data = {
  title: 'Event Title',
  description: 'Event Description',
  start_date: Time.now.iso8601,
  end_date: (Time.now + 60*60*2).iso8601, # 2 hours later
  location_type: 'virtual',
  location: 'Virtual',
  is_unlisted: false,
  status: 'published'
}

result = Tightknit.client.calendar_events.create(event_data)
```

#### Update an Event

```ruby
event_data = {
  title: 'Updated Event Title',
  description: 'Updated Event Description'
}

result = Tightknit.client.calendar_events.update('event_id', event_data)
```

#### Delete an Event

```ruby
result = Tightknit.client.calendar_events.delete('event_id')
```

#### Format an Event for Display

```ruby
event = Tightknit.client.calendar_events.get('event_id')
formatted_event = Tightknit.client.calendar_events.format(event[:data])
```

## Documentation

The gem includes comprehensive YARD documentation. To generate the documentation, first ensure you have the required dependencies:

```bash
bundle install
```

Then generate the documentation with:

```bash
bundle exec rake yard
```

This will generate the documentation in the `doc/yard` directory. To view the documentation in your browser, run:

```bash
bundle exec rake yard_open
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saalik/tightknit.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tightknit project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/tightknit/blob/main/CODE_OF_CONDUCT.md).
