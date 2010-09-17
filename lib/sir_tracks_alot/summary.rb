module SirTracksAlot
  class Summary < Persistable
    attribute :date # 234234234
    attribute :views
    attribute :visits
    
    index :date
  end
end