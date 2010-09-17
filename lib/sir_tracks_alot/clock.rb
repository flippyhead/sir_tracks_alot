module SirTracksAlot
  class Clock
    def self.now
      Time.now.utc.to_i
    end
    
    def self.convert(human)
      Time.parse(human).to_i
    end
  end
end