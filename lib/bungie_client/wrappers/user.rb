module BungieClient::Wrappers
  class User < Default
    attr_reader :membership_type, :display_name

    # Initialize wrapper with user's preset
    #
    # @note maybe add the `destiny_membership_id` as an alternative to `display_name`
    #
    # @option options [Integer] :membership_type Platform type number (xbox - 1, playstation - 2, all - 256)
    # @option options [String] :display_name Simple user name
    def initialize(options)
      super

      # set membershipType
      if %w(1 2 256).include? options[:membership_type].to_s
        @membership_type = options[:membership_type].to_s
      else
        @membership_type = '256'
      end

      # set displayName
      if options[:display_name].is_a? String
        @display_name = options[:display_name]
      else
        raise 'You must set user display name'
      end

      # set destinyMembershipId if needed
      @destiny_membership_id = options[:destiny_membership_id] unless options[:destiny_membership_id].nil?
    end

    # Get DestinyMembershipId of selected user
    def destiny_membership_id
      return @destiny_membership_id unless @destiny_membership_id.nil?

      @destiny_membership_id = call_service(
        'get_membership_id_by_display_name',
        {
          :displayName =>  @display_name,
          :membershipType => @membership_type
        }
      )
    end

    def fill_url(url, params)
      params = {} unless params.is_a? Hash

      params[:displayName] = @display_name
      params[:membershipType] = @membership_type
      params[:destinyMembershipId] = destiny_membership_id if url.include? '{destinyMembershipId}'
      params[:membershipId] = destiny_membership_id if url.include? '{membershipId}'

      super
    end
  end
end
