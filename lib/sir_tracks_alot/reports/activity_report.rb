module SirTracksAlot
  module Reports
    class ActivityReport < SirTracksAlotReport            
      COLUMN_NAMES = ['actor', 'action', 'target', 'event']
      LIMIT = 10000
      
      stage :report      
      required_option :owner
      
      def setup
        super    
        options.column_names ||= COLUMN_NAMES
        
        activities = Activity.recent({:owner => options.owner}, :order => 'DESC', :limit => (options.limit || LIMIT))        
        events = activities.collect{|a| [a.actor, a.action, a.target, a.last_event]}.reject{|a| a[2].nil?}
        
        table = Table(options.column_names, :data => events)
        table.sort_rows_by!('event', :order => :descending)
        
        self.data = table
      end  
                  
      module Helpers
        include Report::Helpers        
      end


      class HTML < Ruport::Formatter::HTML
        renders :html, :for => ActivityReport

        build :report do
          output << erb((options.template || TRACKABLE_ROOT+"/views/reports/table.html.erb"), :binding => binding)
        end    
      end                  
    end
  end
end