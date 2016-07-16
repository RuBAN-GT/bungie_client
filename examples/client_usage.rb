$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bungie_client'
require 'redis'

# init client
client = BungieClient::Client.new(
  :api_key => '1234',
  :cache => BungieClient::Cache.new(
    :ttl    => 900,
    :client => Redis.new,
    :get    => Proc.new { |c, key| c.get key },
    :set    => Proc.new { |c, key, value, ttl| c.setex key, ttl, value }
  )
)

# search account
s = client.get_response "Destiny/SearchDestinyPlayer/2/RuBAN-GT"

p s = s.first if !s.nil? && s.length == 1

# get profile with characters
p client.get_response "Destiny/#{s['membershipType']}/Account/#{s['membershipId']}" unless s.nil?
