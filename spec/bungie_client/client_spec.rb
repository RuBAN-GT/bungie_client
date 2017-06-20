require 'spec_helper'

describe BungieClient::Client do
  it 'returns Destiny profile' do
    stub_request(:get, 'https://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/2/RuBAN-GT').
    with(:headers => { 'X-API-Key' => 'good_key' }).
    to_return(
      :body => File.open(File.expand_path('../../fixtures/search_destiny_player.json', __FILE__))
    )

    client = BungieClient::Client.new(:api_key => 'good_key')

    response = client.get "Destiny/SearchDestinyPlayer/2/RuBAN-GT"

    expect(response&.ErrorCode).to eq(1)
  end

  it 'returns error for bad api key' do
    stub_request(:get, /bungie.net/).
    with(:headers => { 'X-API-Key' => 'bad_key' }).
    to_return(
      :body => File.open(File.expand_path('../../fixtures/invalid_key.json', __FILE__))
    )

    client = BungieClient::Client.new(:api_key => 'bad_key')

    response = client.get "Destiny/SearchDestinyPlayer/2/RuBAN-GT"

    expect(response&.ErrorCode).to eq(2101)
  end

  it 'returns empty answer from wrong request' do
    stub_request(:get, /bungie.net/).to_return(
      :status => 404,
      :body => '<p>Some html with error...</p>'
    )

    client = BungieClient::Client.new(:api_key => 'good_key')

    expect(client.get("Destiny/WRONG_URL")).to eq(Hashie::Mash.new)
  end
end
