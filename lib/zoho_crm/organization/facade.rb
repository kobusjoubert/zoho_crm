# frozen_string_literal: true

class ZohoCrm::Organization::Facade
  attr_reader :id, :attributes

  def initialize(hash)
    @id         = hash['org'][0]['id']
    @attributes = hash['org'][0]
  end
end
