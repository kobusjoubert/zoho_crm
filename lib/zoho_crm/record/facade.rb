# frozen_string_literal: true

class ZohoCrm::Record::Facade
  attr_reader :id, :attributes

  def initialize(hash)
    @id         = hash['data'] ? (hash['data'][0]['id'] || hash['data'][0].dig('details', 'id')) : hash['id']
    @attributes = hash['data'] ? hash['data'][0] : hash
  end
end
