# frozen_string_literal: true

class ZohoCrm::BaseService < ActiveCall::Base
  include ActiveCall::Api

  self.abstract_class = true

  CACHE_KEY = { access_token: 'zoho_sign/base_service/access_token' }.freeze

  config_accessor :base_url, default: 'https://www.zohoapis.com/crm/v7', instance_writer: false
  config_accessor :cache, default: ActiveSupport::Cache::MemoryStore.new, instance_writer: false
  config_accessor :logger, default: Logger.new($stdout), instance_writer: false
  config_accessor :log_level, default: :info, instance_writer: false
  config_accessor :log_headers, default: false, instance_writer: false
  config_accessor :log_bodies, default: false, instance_writer: false
  config_accessor :client_id, :client_secret, :refresh_token, instance_writer: false

  attr_reader :access_token, :facade

  before_call :set_access_token

  validate on: :request do
    next if is_a?(ZohoCrm::AccessToken::GetService) || is_a?(ZohoCrm::GrantToken::GetService)

    errors.merge!(access_token_service.errors) if access_token.nil? && !access_token_service.success?
  end

  class << self
    def exception_mapping
      {
        validation_error:              ZohoCrm::ValidationError,
        request_error:                 ZohoCrm::RequestError,
        client_error:                  ZohoCrm::ClientError,
        server_error:                  ZohoCrm::ServerError,
        bad_request:                   ZohoCrm::BadRequestError,
        unauthorized:                  ZohoCrm::UnauthorizedError,
        forbidden:                     ZohoCrm::ForbiddenError,
        not_found:                     ZohoCrm::NotFoundError,
        method_not_allowed:            ZohoCrm::MethodNotAllowedError,
        not_acceptable:                ZohoCrm::NotAcceptableError,
        proxy_authentication_required: ZohoCrm::ProxyAuthenticationRequiredError,
        request_timeout:               ZohoCrm::RequestTimeoutError,
        conflict:                      ZohoCrm::ConflictError,
        gone:                          ZohoCrm::GoneError,
        payload_too_large:             ZohoCrm::PayloadTooLargeError,
        unsupported_media_type:        ZohoCrm::UnsupportedMediaTypeError,
        unprocessable_entity:          ZohoCrm::UnprocessableEntityError,
        too_many_requests:             ZohoCrm::TooManyRequestsError,
        internal_server_error:         ZohoCrm::InternalServerError,
        not_implemented:               ZohoCrm::NotImplementedError,
        bad_gateway:                   ZohoCrm::BadGatewayError,
        service_unavailable:           ZohoCrm::ServiceUnavailableError,
        gateway_timeout:               ZohoCrm::GatewayTimeoutError
      }.freeze
    end
  end

  private

  def connection
    @_connection ||= Faraday.new do |conn|
      conn.url_prefix = base_url
      # conn.headers['If-Modified-Since'] = '2019-07-25T15:26:49+05:30'
      conn.request :authorization, 'Zoho-oauthtoken', access_token
      conn.request :json
      conn.request :retry
      conn.response :json
      conn.response :logger, logger, **logger_options do |logger|
        logger.filter(/(Authorization:).*"(.+)."/i, '\1 [FILTERED]')
      end
      conn.adapter Faraday.default_adapter
    end
  end

  def logger_options
    {
      headers:   log_headers,
      log_level: log_level,
      bodies:    log_bodies,
      formatter: Faraday::Logging::ColorFormatter, prefix: { request: 'ZohoCrm', response: 'ZohoCrm' }
    }
  end

  def set_access_token
    @access_token = cache.read(CACHE_KEY[:access_token])
    return if @access_token.present?
    return unless access_token_service.success?

    @access_token = cache.fetch(CACHE_KEY[:access_token], expires_in: [access_token_service.expires_in - 10, 0].max) do
      access_token_service.facade.access_token
    end
  end

  def access_token_service
    @_access_token_service ||= ZohoCrm::AccessToken::GetService.call
  end

  def too_many_requests?
    return false unless response.status == 400 && response.body.key?('error_description')

    response.body['error_description'].include?('too many requests')
  end
end
