# Class Client for GET/POST requests to Bungie.
# For specific HTTP operations you can use @agent [Mechanzie].
class BungieClient::Client
  BUNGIE_URI = 'https://www.bungie.net/Platform'

  # Form uri for requests
  #
  # @param [String] uri
  # @return [String]
  def self.request_uri(uri)
    "#{BUNGIE_URI}/#{uri.sub(/^\//, '').sub(/\/$/, '')}/"
  end

  # Format answer from bungie
  #
  # @param [String] response
  #
  # @return [Hashie::Mash]
  def self.parse_response(response)
    if !response.nil? && response != ''
      response = JSON.parse response

      if response.is_a?(Hash) && !response['Response'].nil? && response['ErrorCode'] == 1
        response = Hashie::Mash.new response

        return response['Response']
      end
    end

    Hashie::Mash.new
  end

  attr_reader :api_key
  attr_reader :username
  attr_reader :password
  attr_reader :type
  attr_reader :agent

  # Init client
  #
  # @see https://www.bungie.net/en/user/api
  #
  # Initialize client for bungie api throw hash:
  #
  # @param [Hash] options
  # @option options [String] :api_key
  # @option options [Array|CookieJar] :cookies with [HTTP::Cookie] or [CookieJar]
  # @option options [String] :username username for authentication, necessary if set :authenticate
  # @option options [String] :password password of user, necessary if set :authenticate
  # @option options [String] :type of account, it can be 'psn' or 'live'
  def initialize(options)
    # checking options and @api_key
    raise 'Wrong options: It must be Hash.' unless options.is_a? Hash

    if options[:api_key].nil?
      raise "The API-key required for every request to bungie."
    else
      @api_key = options[:api_key].to_s
    end

    # init @agent
    @agent = Mechanize.new do |config|
      config.read_timeout = 5
    end

    # merge cookies with options
    if BungieClient::Auth.valid_cookies? options[:cookies], true
      cookies = (options[:cookies].is_a? CookieJar) ? options[:cookies].cookies : options[:cookies]

      cookies.each do |cookie|
        @agent.cookie_jar.add cookie
      end
    end unless options[:cookies].nil?

    # make authentication and save new cookies in client
    unless options[:username].nil? || options[:password].nil?
      jar = BungieClient::Auth.auth options[:username].to_s, options[:password].to_s, (options[:type].to_s || 'psn')

      if jar.nil?
        raise "Wrong authentication. Check your account data."
      else
        jar.cookies.each do |cookie|
          @agent.cookie_jar.add cookie
        end
      end
    end
  end

  # Get response from bungie services
  #
  # @see http://destinydevs.github.io/BungieNetPlatform/docs/Endpoints
  #
  # @param [String] uri
  # @param [Hash|Array] parameters for http-query
  #
  # @return [String|nil]
  def get(uri, parameters = {})
    @agent.get(self.class.request_uri(uri), parameters, nil, headers).body rescue nil
  end

  # Get Response field after sending GET request to bungie
  #
  # @param [String] uri
  # @param [Hash|Array] parameters for http-query
  #
  # @return [Hashie::Mash]
  def get_response(uri, parameters = {})
    self.class.parse_response get(uri, parameters)
  end

  # Post data to bungie services
  #
  # @param [String] uri
  # @param [Hash] query
  #
  # @return [String|nil]
  def post(uri, query = {})
    @agent.post(self.class.request_uri(uri), query, headers).body rescue nil
  end

  # Get Response field after post request to bungie
  #
  # @param [String] uri
  # @param [Hash] query for post
  #
  # @return [Hashie::Mash]
  def post_response(uri, query = {})
    self.class.parse_response post(uri, query)
  end

  protected

    # Headers for requests
    def headers
      {
        'Accept' => 'json',
        'Content-Type' => 'json',
        'X-API-Key' => @api_key
      }
    end
end
