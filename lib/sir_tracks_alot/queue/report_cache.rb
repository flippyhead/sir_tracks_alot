module SirTracksAlot
  module Queue
    class ReportCache < Persistable    
      attribute :created_at
      attribute :report
      attribute :owner
      attribute :html
    
      index :report
      index :owner
    end
  end
end