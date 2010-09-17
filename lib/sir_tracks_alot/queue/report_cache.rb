module SirTracksAlot
  module Queue
    class ReportCache < Persistable    
      attribute :created_at
      attribute :report
      attribute :owner
      attribute :name
      attribute :html
    
      index :name
      index :report
      index :owner
    end
  end
end