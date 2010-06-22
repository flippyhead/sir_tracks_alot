module SirTracksAlot
  module Queue
    class ReportConfig < Persistable
      SESSION_DURATION = 1800
      LIMIT = 10000
    
      attribute :created_at
      attribute :report
      attribute :owner
      attribute :options_store

      index :report
      index :owner

      def options
        self.options = {:limit => LIMIT, :session_duration => SESSION_DURATION} if options_store.nil?
        Marshal.load(options_store)
      end
    
      def options=(opts)
        update(:options_store => Marshal.dump(opts))
      end
        
      def validate
        assert_present :report
        assert_present :owner      
      end
    end
  end
end