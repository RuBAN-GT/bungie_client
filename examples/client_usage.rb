$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bungie_client'

# init client
client = BungieClient::Client.new(
  :api_key => 'YOUR_API_KEY'
)

# search account
s = client.get_response "Destiny/SearchDestinyPlayer/2/RuBAN-GT"

p s = s.first if !s.nil? && s.length == 1

# get profile with characters
p client.get_response "Destiny/#{s['membershipType']}/Account/#{s['membershipId']}" unless s.nil?
