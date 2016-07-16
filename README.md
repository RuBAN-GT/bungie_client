[![Gem Version](https://badge.fury.io/rb/bungie_client.svg)](https://badge.fury.io/rb/bungie_client)

# Bungie Client

This gem makes possible to use [Bungie API](http://destinydevs.github.io/BungieNetPlatform/docs/Endpoints) (and Destiny API too) with authentication if necessary.  
It can be useful, if you decide create your application for [Destiny Game](https://www.bungie.net/en/pub/AboutDestiny).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bungie_client'
```

Or install it yourself as:

    $ gem install bungie_client

## Usage

For public requests you must initialize a client of api with `BungieClient::Client`.

~~~~ruby
client = BungieClient::Client.new :api_key => '1234'
~~~~

The option `api_key` only necessary for this class and API. For getting API key, please visit the [bungie page](https://www.bungie.net/en/user/api).

After it you can send your request to [Bungie Endpoint](http://destinydevs.github.io/BungieNetPlatform/docs/Endpoints).

The full information about classes and modules and their methods you can find in yard-comments and [rubydoc](http://www.rubydoc.info/gems/bungie_client).

### BungieClient::Auth

This module has two methods: authentication in bungie.net by PSN or Xbox Live and checking this authentication with cookies that was returned early.

**Example:**

~~~~ ruby
# Authenticate and get bungie cookies
jar = BungieClient::Auth.auth  'example@mail.com', 'example', 'psn'

# Check authentication
p BungieClient::Auth.auth_possible? (jar || [])
~~~~

### BungieClient::Cache

It's class created for easy wrapping another cache clients, e.g. [Redis](https://github.com/redis/redis-rb).

**Examples of initialization:**

~~~~ruby
require 'redis'

BungieClient::Cache.new(
  :ttl    => 900,
  :client => Redis.new,
  :get    => Proc.new { |c, key| c.get key },
  :set    => Proc.new { |c, key, value, ttl| c.setex key, ttl, value }
)
~~~~

**For Rails wrapper:**

~~~~ruby
BungieClient::Cache.new(
  :ttl    => @ttl,
  :client => Rails.cache,
  :get    => Proc.new { |c, key| c.read key },
  :set    => Proc.new { |c, key, value, ttl| c.write key, value, expires_in: ttl }
)
~~~~

### BungieClient::Client

It's main class that makes possible to send any requests to Bungie and connects cache wrapper and auth module in one client.

**For this you should initialize your client for the next example:**

~~~~ruby
client = BungieClient::Client.new(
  :api_key => 'YOUR_API_KEY',
  :authentication => true,
  :username => 'test@test.test',
  :password => '1234',
  :type     => 'psn',
  :cache => BungieClient::Cache.new(
    :ttl    => 900,
    :client => Redis.new,
    :get    => Proc.new { |c, key| c.get key },
    :set    => Proc.new { |c, key, value, ttl| c.setex key, ttl, value }
  )
)
~~~~

#### How it initialized:

* Before working the client tries to authenticate in bungie, if you pass `authentication` option with account data, and after it uses cookies for next requests.
* If store your cookies in any place you can define they with `cookies` option without `authentication`.
* For requests optimization you should use caching of your requests defined `BungieClient::Cache` in `cache` option.
* After this operations your client is done for usage.

> The authentication and caching are optional for client, it requires only `api_key` in your hash.

#### Sending requests

**Now you can send requests, e.g. for finding user information and getting his profile:**

~~~~ruby
# search account
s = client.get_response "Destiny/SearchDestinyPlayer/2/RuBAN-GT"

p s = s.first if !s.nil? && s.length == 1

# get profile with characters
p client.get_response "Destiny/#{s['membershipType']}/Account/#{s['membershipId']}" unless s.nil?
~~~~

## One sample of Rails integration

If you want to work with Rails you can create easy wrapper, such as:

~~~~ ruby
require 'bungie_client'

class RailsBungieWrapper
  class << self
    def api_key=(value)
      @api_key = value
    end
    def ttl=(value)
      @ttl = value
    end

    def init
      yield(self) if block_given?
    end

    def client
      return @client unless @client.nil?

      @client = BungieClient::Client.new(
        :api_key => @api_key,
        :cache => BungieClient::Cache.new(
          :ttl    => @ttl,
          :client => Rails.cache,
          :get    => Proc.new { |c, key| c.read key },
          :set    => Proc.new { |c, key, value, ttl| c.write key, value, expires_in: ttl }
        )
      )
    end
  end
end
~~~~

After it, you should add your initializer to `config\initializers`:

~~~~ruby
RailsBungieWrapper.init do |config|
  config.api_key = '1234'
end
~~~~

In next operations the `RailsBungieWrapper.client` will be available for calls.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RuBAN-GT/bungie_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Fireteam

If you want to fight with Oryx with me or create any interesting applications for Destiny, you can add me ([https://www.bungie.net/en/Profile/254/12488384](https://www.bungie.net/en/Profile/254/12488384)).
