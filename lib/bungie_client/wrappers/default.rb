# Wrapper class for simple api requests
module BungieClient::Wrappers
  class Default
    # Initialize wrapper with client
    #
    # This initializer create wrapper object with client.
    # If you `options` contain `:client` key, it will be taken as client object [BungieClient::Client]. Otherwise it will be passed in client initializer.
    #
    # @see BungieClient::Client
    #
    # @param [BungieClient::Client] client initialized for wrapper
    # @param [Hash] options for initialization of client
    def initialize(options = {})
      if options[:client].nil?
        @options = options
      elsif options[:client].is_a? BungieClient::Client
        @client = options[:client]
      end
    end

    # Get wrapper client
    #
    # @return [BungieClient::Client]
    def client
      return @client unless @client.nil?

      @client = BungieClient::Client.new @options
    end

    # Change all url parameters to hash value
    #
    # @param [String] url
    # @param [Hash] params
    #
    # @return [String]
    def fill_url(url, params)
      params.each do |key, value|
        url = url.gsub "{#{key}}", value.to_s
      end

      url
    end

    # Call needed service from services list
    #
    # @param [String] service name in snake case
    # @param [Hash] params service parameters
    # @param [Hash] options for client request (get/post)
    #
    # @return [Hashie::Mash]
    def call_service(service, params = {}, options = {})
      service = BungieClient::Service.new service rescue raise NoMethodError

      # change url
      url = self.fill_url service.endpoint, params

      # send request
      client.send service.type, url, options
    end

    def method_missing(*args)
      call_service args[0].to_s, args[1], args[2]
    end
  end
end
