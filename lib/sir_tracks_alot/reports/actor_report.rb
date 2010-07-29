module SirTracksAlot
  module Reports
    class ActorReport < SirTracksAlotReport                
      COLUMN_NAMES = ['actor', 'page views', 'visits']
      
      stage :actor
      required_option :owner
      
      def setup
        super
        options.column_names ||= COLUMN_NAMES
        options.counts ||= {}
        
        table = Table(options.column_names) do |t|
          options.counts.each do |actor, count|
            t << [actor, count[0], count[1]]
          end
        end
        
        table.sort_rows_by!('page views', :order => :descending)
        
        self.data = table
      end  
                  
      module Helpers
        include Report::Helpers        
      end


      class HTML < Ruport::Formatter::HTML
        renders :html, :for => ActorReport

        build :actor do
          output << erb((options.template || TRACKABLE_ROOT+"/views/reports/table.html.erb"), :binding => binding)
        end    
      end                  
    end
  end
end