# frozen_string_literal: true

class ZohoCrm::Record::UpsertService < ZohoCrm::BaseService
  attr_reader :module_name, :data, :duplicate_check_fields, :skip_feature_execution, :trigger

  validates :module_name, :data, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(module_name:, data:, duplicate_check_fields: [], skip_feature_execution: [], trigger: [])
    @module_name            = module_name
    @data                   = data.is_a?(Array) ? data : [data]
    @duplicate_check_fields = duplicate_check_fields
    @skip_feature_execution = skip_feature_execution
    @trigger                = trigger
  end

  # Create a record.
  #
  # https://www.zoho.com/crm/developer/docs/api/v7/upsert-records.html
  #
  # ==== Examples
  #
  #   service = ZohoCrm::Record::UpsertService.call(
  #     module_name: 'Contacts',
  #     data: {
  #       'Email' => 'eric.cartman@example.com',
  #       'First_Name' => 'Eric',
  #       'Last_Name' => 'Cartman Theodore 2nd'
  #     },
  #     duplicate_check_fields: ['Email']
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
  # POST /crm/v7/:module_name/upsert
  def call
    connection.post("#{module_name}/upsert", **params)
  end

  private

  def params
    {
      data:                   data,
      duplicate_check_fields: duplicate_check_fields,
      skip_feature_execution: skip_feature_execution,
      trigger:                trigger
    }.compact_blank
  end

  def set_facade
    @facade = ZohoCrm::Record::Facade.new(response.body)
  end
end
