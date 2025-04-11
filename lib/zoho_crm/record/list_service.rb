# frozen_string_literal: true

class ZohoCrm::Record::ListService < ZohoCrm::BaseService
  SORT_COLUMNS = %w[id Created_Time Modified_Time].freeze
  SORT_ORDERS  = %w[asc desc].freeze

  include ZohoCrm::Enumerable

  attr_reader :module_name, :fields, :sort_by, :sort_order

  validates :module_name, :fields, presence: true
  validates :sort_order, inclusion: { in: SORT_ORDERS, message: "Sort order must be one of #{SORT_ORDERS.join(', ')}" }

  validates :sort_by, inclusion: {
    in:      SORT_COLUMNS,
    message: "Sort by must be one of #{SORT_COLUMNS.join(', ')}"
  }

  # List records.
  #
  # https://www.zoho.com/crm/developer/docs/api/v7/get-records.html
  #
  # ==== Examples
  #
  #   service = ZohoCrm::Record::ListService.call(module_name: 'Contacts', fields: 'Email,Last_Name').first
  #   service.id
  #
  # If you don't provide the `per_page` argument, multiple API requests will be made untill all records have been
  # returned. You could be rate limited, so use wisely.
  #
  #   ZohoCrm::Record::ListService.call(module_name: 'Contacts', fields: 'Email,Last_Name', page: 1, per_page: 10).each { _1 }
  #
  # Sort by column.
  #
  #   ZohoCrm::Record::ListService.call(module_name: 'Contacts', fields: 'Email,Last_Name', sort_by: 'id', sort_order: 'asc').map { _1 }
  #
  # Columns to sort by are `id`, `Created_Time` and `Modified_Time`.
  #
  # GET /crm/v7/:module_name
  def initialize(module_name:, fields:, page: 1, per_page: Float::INFINITY, sort_by: 'id', sort_order: 'desc')
    @module_name = module_name
    @fields      = fields
    @sort_by     = sort_by
    @sort_order  = sort_order

    super(
      path:         module_name,
      list_key:     'data',
      facade_klass: ZohoCrm::Record::Facade,
      page:         page,
      per_page:     per_page
    )
  end

  private

  def params
    @_params ||= {
      page:       page,
      per_page:   max_per_page_per_request,
      sort_by:    sort_by,
      sort_order: sort_order,
      fields:     fields
    }
  end
end
