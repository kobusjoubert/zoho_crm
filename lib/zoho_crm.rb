# frozen_string_literal: true

require 'active_call'
require 'active_call/api'

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/active_call-zoho_crm.rb")
loader.ignore("#{__dir__}/zoho_crm/error.rb")
loader.collapse("#{__dir__}/zoho_crm/concerns")
loader.setup

require_relative 'zoho_crm/error'
require_relative 'zoho_crm/version'

module ZohoCrm; end
