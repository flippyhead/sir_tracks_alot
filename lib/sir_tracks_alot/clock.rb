module SirTracksAlot
  class Clock
    def self.now
      Time.now.utc.to_i
    end
  end
end