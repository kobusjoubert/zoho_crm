# frozen_string_literal: true

class ZohoCrm::Organization::GetService < ZohoCrm::BaseService
  after_call :set_facade

  delegate_missing_to :@facade

  # Get a document.
  #
  # https://www.zoho.com/crm/developer/docs/api/v7/get-org-data.html
  #
  # ==== Examples
  #
  #   service = ZohoCrm::Organization::GetService.call
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<ZohoCrm::Organization::Facade ...>
  #   service.facade.attributes
  #   service.attributes
  #
  # GET /crm/v7/org
  def call
    connection.get('org')
  end

  private

  def set_facade
    @facade = ZohoCrm::Organization::Facade.new(response.body)
  end
end
