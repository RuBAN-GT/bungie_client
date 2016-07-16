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

  attr_reader :api_key
  attr_reader :username
  attr_reader :password
  attr_reader :type
  attr_reader :agent
  attr_reader :cache

  # Init client
  #
  # @see https://www.bungie.net/en/user/api
  #
  # Initialize client for bungie api throw hash:
  #
  # @param [Hash] options
  # @option options [String] :api_key
  # @option options [Array] :cookies with [HTTP::Cookie]
  # @option options [BungieClient::Cache] :cache client for saving respones
  # @option options [Boolean] :authentication makes authentication with next three field for getting cookies for private requests
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

    # init @cache
    unless options[:cache].nil?
      if options[:cache].is_a? BungieClient::Cache
        @cache = options[:cache]
      else
        raise 'Cache client must be inhereted from [BungieClient::Cache].'
      end
    end

    # init @agent
    @agent = Mechanize.new

    # make authentication
    if options[:authentication]
      @username = options[:username]  if options[:username].is_a? String
      @password = options[:password]  if options[:password].is_a? String
      @type     = options[:type].to_s if ['psn', 'live'].include? options[:type].to_s

      cookies = BungieClient::Auth.auth @username, @password, (@type || 'psn')

      if cookies.nil?
        raise "Wrong authentication. Check your account data."
      else
        @agent.cookie_jar = cookies
      end
    end

    # merge cookies with options
    if BungieClient::Auth.valid_cookies? options[:cookies], true
      cookies = (options[:cookies].is_a? Array) ? cookies : cookies.cookies

      cookies.each do |cookie|
        @agent.cookie_jar.add cookie
      end
    end unless options[:cookies].nil?
  end

  # Check options for allowing getting of cache
  #
  # @param [Hash] options of cache
  #
  # @return [Boolean]
  def allow_get_cache(options = {})
    allow_set_cache(options) && options[:cache_rewrite] != true
  end

  # Check options for allowing setting of cache
  #
  # @param [Hash] options of cache
  #
  # @return [Boolean]
  def allow_set_cache(options = {})
    !@cache.nil? && options[:cache_none] != true
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

  # Get Response field after get request to bungie
  #
  # @param [String] uri
  # @param [Hash|Array] parameters for http-query
  # @param [Hash] options for cache such as:
  # @option options [Boolean] :cache_none - disable response caching
  # @option options [Boolean] :cache_rewrite - update cache value
  # @option options [Integer] :cache_ttl - special cache ttl
  #
  # @return [Array|Hash|nil]
  def get_response(uri, parameters = {}, options = {})
    if allow_get_cache options
      result = @cache.get "#{uri}+#{parameters}"

      return result unless result.nil?
    end

    result = get uri, parameters

    if !result.nil? && result != ''
      result = JSON.parse result

      if !result['Response'].nil? && !result['ErrorCode'].nil? && result['ErrorCode'] == 1
        @cache.set "#{uri}+#{parameters}", result['Response'], options[:cache_ttl] if allow_set_cache options

        result['Response']
      end
    end
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
