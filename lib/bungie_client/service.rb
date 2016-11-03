# Simple class for service structure
class BungieClient::Service
  attr_reader :method_type, :name, :endpoint

  def initialize(options)
    @method_type = ((%w(get post).include? options[:method]) ? options[:method] : 'get')
    @name        = options[:name].to_s
    @endpoint    = options[:endpoint].to_s
  end
end