# frozen_string_literal: true

require 'yaml'
require 'hashie'
require 'nokogiri'
require 'open-uri'
require 'underscore'

# This task can parse the list of bungie services from *destinydevs.github.io* for client.
task :parse_services do
  # preset
  services = {}
  response = Nokogiri::HTML open('http://destinydevs.github.io/BungieNetPlatform/docs/Endpoints')

  # get services
  response.search('.container .table tbody tr').each do |tr|
    tds = tr.search 'td'

    next if tds.nil? || tds[1].nil?

    service = {
      name: tds[1].text,
      method: (tds[0]&.text.downcase || 'get'),
      endpoint: (tds[2]&.text || '')
    }
    service[:endpoint].slice! 0

    services[tds[1].text.underscore] = service
  end

  # save yaml
  File.open "#{File.dirname(__FILE__)}/../bungie_client/services.yml", 'w' do |f|
    f.write services.to_yaml
  end

  p 'Services were generated...'
end
