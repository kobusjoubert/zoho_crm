# frozen_string_literal: true

class ZohoCrm::GrantToken::Facade
  attr_reader :access_token, :refresh_token, :scope, :api_domain, :expires_in, :token_type

  def initialize(hash)
    @access_token  = hash['access_token']
    @api_domain    = hash['api_domain']
    @expires_in    = hash['expires_in']
    @refresh_token = hash['refresh_token']
    @scope         = hash['scope']
    @token_type    = hash['token_type']
  end
end
