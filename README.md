# Tightknit 
### 💎 + 🧶 = 🎉

A Ruby client for the [Tightknit](https://tightknit.ai) API.

[Official API docs](https://docs.tightknit.ai)

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add tightknit
```

If bundler is not being used to manage dependencies, install the gem with:

```bash
gem install tightknit
```

## Usage

### Creating a Client

Create a Tightknit client with your API key:

```ruby
require 'tightknit'

# Create a client with your API key
client = Tightknit::Client.new(api_key: 'your_api_key')
```

### Calendar Events

#### List Events

```ruby
# Get events with default parameters (page 0, per_page 10, status 'published')
events = client.calendar_events.list

# With custom parameters
events = client.calendar_events.list(
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
all_events = client.calendar_events.all(
  page: 0,
  per_page: 10,
  status: 'published'
)
```

#### Get a Specific Event

```ruby
event = client.calendar_events.get('event_id')
```

#### Format an Event for Display

```ruby
event = client.calendar_events.get('event_id')
formatted_event = client.calendar_events.format_data(event[:data])
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

Note that if you're adding new API routes, you'll need to add a `.env` file to test requests with your Tightknit API credentials. You can rely on our stubbed VCR cassettes for exisiting routes.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Lok-Bros/tightknit.

Get in touch with us anytime: hello@lokbros.com

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Maintained by [LokBros Studio](https://lokbros.com).
