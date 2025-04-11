# frozen_string_literal: true

class ZohoCrm::Record::SearchService < ZohoCrm::BaseService
  SORT_COLUMNS = %w[id Created_Time Modified_Time].freeze
  SORT_ORDERS  = %w[asc desc].freeze

  include ZohoCrm::Enumerable

  attr_reader :module_name, :sort_by, :sort_order, :email, :phone, :criteria, :word

  validates :module_name, presence: true
  validates :sort_order, inclusion: { in: SORT_ORDERS, message: "Sort order must be one of #{SORT_ORDERS.join(', ')}" }

  validates :sort_by, inclusion: {
    in:      SORT_COLUMNS,
    message: "Sort by must be one of #{SORT_COLUMNS.join(', ')}"
  }

  # List records.
  #
  # https://www.zoho.com/crm/developer/docs/api/v7/search-records.html
  #
  # ==== Examples
  #
  #   service = ZohoCrm::Record::SearchService.call(module_name: 'Contacts', email: 'eric.cartman@example.com').first
  #   service.id
  #
  # If you don't provide the `per_page` argument, multiple API requests will be made untill all records have been
  # returned. You could be rate limited, so use wisely.
  #
  #   ZohoCrm::Record::SearchService.call(module_name: 'Contacts', email: 'eric.cartman@example.com', page: 1, per_page: 10).each { _1 }
  #
  # Sort by column.
  #
  #   ZohoCrm::Record::SearchService.call(module_name: 'Contacts', email: 'eric.cartman@example.com', sort_by: 'Modified_Time', sort_order: 'asc').map { _1 }
  #
  # Columns to sort by are `id`, `Created_Time` and `Modified_Time`.
  #
  # Search by email.
  #
  #   ZohoCrm::Record::SearchService.call(module_name: 'Contacts', email: 'eric.cartman@example.com').map { _1 }
  #
  # Search by phone.
  #
  #   ZohoCrm::Record::SearchService.call(module_name: 'Contacts', phone: '0123456789').map { _1 }
  #
  # Search by criteria.
  #
  #   ZohoCrm::Record::SearchService.call(module_name: 'Contacts', criteria: 'Created_Time:between:2025-01-01T06:00:00+00:00,2025-01-30T06:00:00+00:00').map { _1 }
  #
  # Search by word.
  #
  #   ZohoCrm::Record::SearchService.call(module_name: 'Contacts', word: 'eric').map { _1 }
  #
  # GET /crm/v7/:module_name
  def initialize(module_name:, page: 1, per_page: Float::INFINITY, sort_by: 'id', sort_order: 'desc', email: nil, phone: nil, criteria: nil, word: nil)
    @module_name = module_name
    @sort_by     = sort_by
    @sort_order  = sort_order
    @email       = email
    @phone       = phone
    @criteria    = criteria
    @word        = word

    super(
      path:         "#{module_name}/search",
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
      email:      email,
      phone:      phone,
      criteria:   criteria,
      word:       word
    }.compact_blank
  end
end
