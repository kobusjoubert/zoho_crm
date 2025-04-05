# frozen_string_literal: true

class ZohoCrm::AccessToken::Facade
  attr_reader :access_token, :api_domain, :expires_in, :scope, :token_type

  def initialize(hash)
    @access_token = hash['access_token']
    @api_domain   = hash['api_domain']
    @expires_in   = hash['expires_in']
    @scope        = hash['scope']
    @token_type   = hash['token_type']
  end
end
