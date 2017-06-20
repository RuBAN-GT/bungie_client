require 'spec_helper'

describe BungieClient::Wrappers::Default do
  before do
    stub_request(:get, 'https://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/2/RuBAN-GT/').
      with(:headers => { 'X-API-Key' => 'good_key' }).
      to_return(
        :body => File.open(File.expand_path('../../fixtures/search_destiny_player.json', __FILE__))
      )
  end

  it 'calls search_destiny_player service and returns filled hash' do
    wrapper  = BungieClient::Wrappers::Default.new :api_key => 'good_key'
    response = wrapper.search_destiny_player :membershipType => 2, :displayName => 'RuBAN-GT'

    expect(response&.ErrorCode).to eq(1)
  end

  it 'calls serach_destiny_player service with user wrapper' do
    guardian = BungieClient::Wrappers::User.new(
      :api_key => 'good_key',
      :membership_type => 2,
      :display_name => 'RuBAN-GT'
    )
    response = guardian.search_destiny_player

    expect(response&.ErrorCode).to eq(1)
  end
end
