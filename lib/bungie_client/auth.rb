# Module Auth with two methods: authentication in bungie.net by PSN or Xbox Live and checking this authentication with cookies that was returned early.
module BungieClient::Auth
  class << self
    # Check cookies for private requests
    #
    # @param [Array] cookies with [HTTP::Cookie]
    # @param [Boolean] raise cookie errors
    #
    # @return [Boolean]
    def valid_cookies?(cookies, raise = false)
      if cookies.is_a? Mechanize::CookieJar
        cookies = cookies.cookies
      elsif !(cookies.is_a?(Array) && cookies.all? { |c| c.is_a? HTTP::Cookie })
        raise "Wrong cookie option: It must be Array with HTTP::Cookie elements or CookieJar." if raise

        return false
      end

      needed = %w(bungled bungleatk bungles)
      cookies.each do |cookie|
        if needed.include?(cookie.name) && cookie.expired? == false
          needed.delete cookie.name

          return true if needed.length == 0
        end
      end

      (raise) ? raise("Your argument doesn't have all needed cookies for private requests #{needed.join ','}.") : false
    end

    # Full authentication of user
    #
    # @param [String] username user email for auth
    # @param [String] password user password for auth
    # @param [String] type can be psn or live
    #
    # @return [Mechanize::CookieJar|nil]
    def auth(username, password, type = 'psn')
      # client init
      agent = Mechanize.new do |config|
        config.open_timeout = 60
        config.read_timeout = 60
        config.idle_timeout = 120
      end

      # getting index page
      agent.get 'https://www.bungie.net/' do |page|
        result = nil
        link   = page.link_with :text => search_query(type)

        unless link.nil?
          # call auth page
          login = agent.click link

          # sending form for sony or ms
          if type == 'psn'
            form = login.forms.first
            unless form.nil?
              name = form.field_with(:type => 'email')
              pass = form.field_with(:type => 'password')

              if !name.nil? && !pass.nil?
                name.value = username
                pass.value = password

                result = form.click_button
              end
            end
          else
            # ms wanted enabled js, but we can send form without it
            ppft = login.body.match(/name\="PPFT"(.*)value\="(.*?)"/)
            url  = login.body.match(/urlPost\:'(.*?)'/)

            if !ppft.nil? && !url.nil?
              result = agent.post url.to_a.last,
                'login' => username,
                'passwd' => password,
                'KMSI' => 1,
                'PPFT' => ppft.to_a.last
            end
          end
        end

        # if result not nil and after authentication we returned to bungie, all ok
        if !result.nil? && result.uri.to_s.include?('?code')
          needed = %w(bungled bungleatk bungledid bungles)
          output = Mechanize::CookieJar.new

          agent.cookies.each do |cookie|
            output.add cookie if needed.include? cookie.name
          end

          return output
        end
      end

      nil
    end

    # Try authenticate with cookies
    #
    # @param [Array|CookieJar] cookies array with [HTTP::Cookie] or [CookieJar]
    #
    # @return [Boolean]
    def auth_possible?(cookies)
      agent = Mechanize.new

      valid_cookies? cookies, true

      if cookies.is_a? Array
        cookies.each do |cookie|
          agent.cookie_jar.add cookie
        end
      else
        agent.cookie_jar = cookies
      end

      result = nil
      agent.get 'https://www.bungie.net/' do |page|
        link = page.link_with :text => search_query('psn')

        result = agent.click link unless link.nil?
      end

      !result.nil? && result.uri.host == "www.bungie.net"
    end

    protected

      def search_query(type)
        if type == 'psn'
          'PlayStation Network'
        elsif type == 'live'
          'Xbox Live'
        else
          raise 'Wrong account type!'
        end
      end
  end
end
