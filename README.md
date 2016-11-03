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

This gem contains two main classes: **BungieClient::Client**, **BungieClient::Wrappers::Default** and his inherits.

### BungieClient::Client

It's main class that makes possible to send any requests to Bungie and connects auth module in one client. It needs for public/private requests to Bungie API.

**For this you should initialize your client for the next example:**

~~~~ruby
@client = BungieClient::Client.new(
  :api_key => 'YOUR_API_KEY',
  :username => 'test@test.test',
  :password => '1234',
  :type     => 'psn'
)
~~~~

**or simply:**

~~~~ruby
@client = BungieClient::Client.new :api_key => 'YOUR_API_KEY'
~~~~

* The option `api_key` only necessary for this class and API. For getting API key, please visit the [bungie page](https://www.bungie.net/en/user/api).
* After it you can send your request to [Bungie Endpoint](http://destinydevs.github.io/BungieNetPlatform/docs/Endpoints).
* The full information about classes and modules and their methods you can find in yard-comments and [rubydoc](http://www.rubydoc.info/gems/bungie_client).

#### How it initialized:

* Before working the client tries to authenticate in bungie, if you pass `username` and `password` option with account data, and after it uses cookies for next requests.
* If you want to store your cookies in any place you can define they with `cookies` option without authentication.
* After this operations your client is done for usage.

> The authentication optional for client, it requires only `api_key` in your hash for initializer.

#### Sending requests

**Now you can send requests, e.g. for finding user information and getting his profile:**

~~~~ruby
@client.get_response "Destiny/SearchDestinyPlayer/2/RuBAN-GT"
~~~~

#### Note

* For requests optimization you should use any caching of your requests.

### BungieClient::Auth

This module has two methods: authentication in bungie.net by *PSN* or *Xbox Live* and checking this authentication with cookies that was returned early.

**Example:**

~~~~ ruby
# Authenticate and get bungie cookies
jar = BungieClient::Auth.auth  'example@mail.com', 'example', 'psn'

# Check authentication
p BungieClient::Auth.auth_possible? (jar || [])
~~~~

### BungieClient::Wrappers::Default

If you don't like long code as for me you should use **Wrappers**. It's classes can call api services with dynamically generated methods with snake case like name services. Also it can change url parameters to needed values and in inherits of this class it can be do automatically.

The initialization of **Wrappers::Default** is similar to **Client**: all arguments of initializer will be passed to **Client** which is class variable of wrapper.

~~~~ruby
@wrapper = BungieClient::Wrappers::Default.new :api_key => 'YOUR_API_KEY'
~~~~

Now you can sending your requests with beautiful and effective code:

~~~~ruby
@wrapper.search_destiny_player :membershipType => '2', :displayName => 'RuBAN-GT'
~~~~

If you need **more** you can define your own wrappers such as **Wrappers::User**:

~~~~ruby
@user = BungieClient::Wrappers::User.new(
  :api_key => 'YOUR_API_KEY',
  :display_name => 'RuBAN-GT',
  :membership_type => '2'
)

@user.search_destiny_player
~~~~

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RuBAN-GT/bungie_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Fireteam

If you want to fight with Oryx with me or create any interesting applications for Destiny, you can add me ([https://www.bungie.net/en/Profile/254/12488384](https://www.bungie.net/en/Profile/254/12488384)).

## Note

* In the source code you can fine `services_parser.rb`. It's script created for getting full list of Bungie API services, for result it generates `services.yml` in lib.