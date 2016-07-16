$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bungie_client'

# Get bungie cookies
jar = BungieClient::Auth.auth 'example@mail.com', 'example', 'psn'
p (jar.nil?) ? 0 : jar.cookies.length

# Check cookies and authentication
p BungieClient::Auth.auth_possible? (jar || [])
