# frozen_string_literal: true

class ZohoCrm::Record::UpdateService < ZohoCrm::BaseService
  attr_reader :module_name, :data

  validates :module_name, :data, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(module_name:, data:)
    @module_name = module_name
    @data        = data.is_a?(Array) ? data : [data]
  end

  # Create a record.
  #
  # ==== Examples
  #
  #   service = ZohoCrm::Record::UpdateService.call(
  #     module_name: 'Contacts',
  #     data: {
  #       'id' => '',
  #       'First_Name' => 'Eric Theodore'
  #     }
  #   )
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
  # PUT /crm/v7/:module_name
  def call
    connection.put(module_name, **params)
  end

  private

  def params
    {
      data: data
    }
  end

  def set_facade
    @facade = ZohoCrm::Record::Facade.new(response.body)
  end
end
