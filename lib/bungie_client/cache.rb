class BungieClient::Cache
  attr_reader :client
  attr_reader :ttl

  # Get value
  #
  # @param [String] key
  #
  # @return [Object]
  def get(key)
    result = @get.call @client, key.to_s

    Marshal.load result unless result.nil?
  end

  # Set value
  #
  # @param [String] key
  # @param [Object] value it can be everything, because it serialized with [Marshal]
  # @param [Integer|nil] ttl
  def set(key, value, ttl = nil)
    @set.call @client, key.to_s, Marshal.dump(value), (ttl || @ttl)
  end

  # Initialize handlers of cache client with options
  #
  # @param [Hash] options with
  # @option options [Class] :client - basic object of cache client, e.g. [Redis]
  # @option options [Proc] :get - method for getting data, it gets key of row on call
  # @option options [Proc] :set - method for setting data, it gets key, value, ttl on call
  # @option options [Integer] :ttl - time to live of row in cache
  def initialize(options = {})
    @ttl = (options[:ttl].is_a?(Integer) && options[:ttl] > 0) ? options[:ttl] : 900

    if options[:client].nil?
      raise 'You must define the client initialization.'
    else
      @client = options[:client]
    end

    if options[:get].is_a? Proc
      @get = options[:get]
    else
      raise 'You must define the get method for caching.'
    end

    if options[:set].is_a? Proc
      @set = options[:set]
    else
      raise 'You must define the set method for caching.'
    end
  end
end
