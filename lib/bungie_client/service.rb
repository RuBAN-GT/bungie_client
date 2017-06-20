# Simple class for service structure
class BungieClient::Service
  attr_reader :type, :name, :endpoint

  # Get list of services
  #
  # @see http://destinydevs.github.io/BungieNetPlatform/docs/Endpoints
  #
  # @return [Hash]
  def self.services
    return @services unless @services.nil?

    @services = YAML.load_file "#{File.dirname(__FILE__)}/services.yml" || {}
  end

  # Initialize service by name with snake case style
  #
  # @example service =
  #
  # @param [String] name
  def initialize(name)
    service = self.class.services[name]

    raise 'Undefined service' if service.nil?

    @type     = service[:method]
    @name     = service[:name]
    @endpoint = service[:endpoint]
  end
end
