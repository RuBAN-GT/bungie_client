$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bungie_client'

# init client
@user = BungieClient::Wrappers::User.new(
  :api_key => 'YOUR_API_KEY',
  :display_name => 'RuBAN-GT',
  :membership_type => '2'
)

p @user.get_bungie_account.keys
