# frozen_string_literal: true

# Class Client for GET/POST requests to Bungie.
# For specific HTTP operations you can use @conn [Faraday].
module BungieClient
  class Client
    BUNGIE_URI = 'https://www.bungie.net/Platform'

    # Format answer from Bungie
    #
    # @param [String] response
    #
    # @return [Mash]
    def self.parse(response)
      response = begin
        MultiJson.load response
      rescue StandardError
        {}
      end

      Hashie::Mash.new response
    end

    attr_reader :api_key, :token, :conn

    # Init client
    #
    # @see https://www.bungie.net/en/user/api
    #
    # Initialize client for bungie api throw hash:
    #
    # @param [Hash] options
    # @option options [String] :api_key
    # @option options [String] :token is authorization token from oauth2
    def initialize(options)
      # Checking options and @api_key
      raise 'Wrong options: It must be Hash.' unless options.is_a? Hash

      if options[:api_key].nil?
        raise 'The API-key required for every request to bungie.'
      else
        @api_key = options[:api_key].to_s
      end

      # Set token
      @token = options[:token].to_s unless options[:token].nil?

      # Init connection
      @conn = Faraday.new url: BUNGIE_URI do |builder|
        builder.headers['Content-Type']  = 'application/json'
        builder.headers['Accept']        = 'application/json'
        builder.headers['X-API-Key']     = @api_key
        builder.headers['Authorization'] = "Bearer #{@token}" unless @token.nil?

        builder.options.timeout      = 5
        builder.options.open_timeout = 2

        builder.use FaradayMiddleware::FollowRedirects, limit: 5

        builder.adapter :httpclient
      end
    end

    # Get request to bungie service
    #
    # @see http://destinydevs.github.io/BungieNetPlatform/docs/Endpoints
    #
    # @param [String] url
    # @param [Hash] parameters for http-query
    # @param [Hash] headers
    #
    # @return [Mash]
    def get(url, parameters = {}, headers = {})
      self.class.parse @conn.get(url, parameters, headers).body
    rescue StandardError
      Hashie::Mash.new
    end

    # Post data to Bungie services
    #
    # @param [String] url
    # @param [Hash] query
    # @param [Hash] headers
    #
    # @return [Mash]
    def post(url, query = {}, headers = {})
      self.class.parse @conn.post(url, query, headers).body
    rescue StandardError
      Hashie::Mash.new
    end
  end
end
