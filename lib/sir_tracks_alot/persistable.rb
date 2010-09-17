require 'ohm'

module SirTracksAlot
  class Persistable < Ohm::Model    
    attribute :created_at

    def self.find_or_create(attributes)
      models = self.find(attributes)
      models.empty? ? self.create(attributes.merge(:created_at => Clock.now)) : models.first
    end

    def hash
      self.id
    end

    # Simply delegate to == in this example.
    def eql?(comparee)
      self == comparee
    end

    # Objects are equal if they have the same
    # unique custom identifier.
    def ==(comparee)
      self.id == comparee.id
    end

    def to_hash
      super
    end


    protected
    
    def self.find_key_from_value(hash, value)
      hash.each do |k, v|
        return k if v.include?(value)
      end
    end    
  end
end