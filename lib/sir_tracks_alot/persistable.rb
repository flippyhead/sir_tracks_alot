require 'ohm'

module SirTracksAlot
  class Persistable < Ohm::Model
    attribute :created_at

    def self.find_or_create(attributes)
      models = self.find(attributes)
      models.empty? ? self.create(attributes.merge(:created_at => Clock.now)) : models.first
    end

    protected    
    
    def validate
    end        
  end
end