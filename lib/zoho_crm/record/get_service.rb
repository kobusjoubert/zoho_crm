# frozen_string_literal: true

class ZohoCrm::Record::GetService < ZohoCrm::BaseService
  attr_reader :module_name, :id

  validates :module_name, :id, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(module_name:, id:)
    @module_name = module_name
    @id          = id
  end

  # Get a document.
  #
  # https://www.zoho.com/crm/developer/docs/api/v7/get-records.html
  #
  # ==== Examples
  #
  #   service = ZohoCrm::Record::GetService.call(module_name: 'Contacts', id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<ZohoCrm::Record::Facade ...>
  #   service.facade.attributes
  #   service.attributes
  #
  # GET /crm/v7/:module_name/:id
  def call
    connection.get("#{module_name}/#{id}")
  end

  private

  def set_facade
    @facade = ZohoCrm::Record::Facade.new(response.body)
  end

  def not_found?
    response.status == 204
  end
end
