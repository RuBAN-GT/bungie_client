# This script can parse the list of bungie services from *destinydevs.github.io* for client.

require 'yaml'
require 'hashie'
require 'mechanize'
require 'underscore'

# preset
client = Mechanize.new
url = 'http://destinydevs.github.io/BungieNetPlatform/docs/Endpoints'
services = {}

# get services
client.get url do |page|
  trs = page.parser.search '.container .table tbody tr'

  trs.each do |tr|
    tds = tr.search 'td'

    next if tds.nil? || tds[1].nil?

    services[tds[1].text.underscore] = {
      :name => tds[1].text,
      :method => (tds[0]&.text.downcase || 'get'),
      :endpoint => (tds[2]&.text || '')
    }
  end unless trs.nil?
end

# save yaml
File.open "#{File.dirname(__FILE__)}/lib/bungie_client/services.yml", 'w' do |f|
  f.write services.to_yaml
end