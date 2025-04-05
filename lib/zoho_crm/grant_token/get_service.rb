# frozen_string_literal: true

class ZohoCrm::GrantToken::GetService < ZohoCrm::BaseService
  attr_reader :grant_token, :client_id, :client_secret

  skip_callback :call, :before, :set_access_token

  after_call :set_facade

  delegate_missing_to :@facade
  delegate :refresh_token, to: :@facade, allow_nil: true

  validates :grant_token, presence: true

  def initialize(grant_token:, client_id: nil, client_secret: nil)
    @grant_token   = grant_token
    @client_id     = client_id.presence || ZohoCrm::BaseService.client_id
    @client_secret = client_secret.presence || ZohoCrm::BaseService.client_secret
  end

  # Get refresh token from grant token.
  #
  # ==== Examples
  #
  #   service = ZohoCrm::GrantToken::GetService.call(grant_token: '', client_id: '', client_secret: '')
  #   service.refresh_token # => '1000.xxxx.yyyy'
  #   service.expires_in # => 3600
  #
  # POST /oauth/v2/token
  def call
    connection.post('oauth/v2/token', params.to_param)
  end

  private

  def connection
    @_connection ||= Faraday.new do |conn|
      conn.url_prefix = 'https://accounts.zoho.com'
      conn.request :retry
      conn.response :json
      conn.response :logger, logger, **logger_options do |logger|
        logger.filter(/(code|client_id|client_secret)=([^&]+)/i, '\1=[FILTERED]')
        logger.filter(/"access_token":"([^"]+)"/i, '"access_token":"[FILTERED]"')
        logger.filter(/"refresh_token":"([^"]+)"/i, '"refresh_token":"[FILTERED]"')
      end
      conn.adapter Faraday.default_adapter
    end
  end

  def params
    {
      client_id:     client_id,
      client_secret: client_secret,
      code:          grant_token,
      grant_type:    'authorization_code'
    }
  end

  def set_facade
    @facade = ZohoCrm::GrantToken::Facade.new(response.body)
  end

  def unauthorized?
    response.status == 200 && response.body.key?('error')
  end
end
