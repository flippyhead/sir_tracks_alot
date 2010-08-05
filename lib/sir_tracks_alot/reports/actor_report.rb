module SirTracksAlot
  module Reports
    class ActorReport < SirTracksAlotReport                
      COLUMN_NAMES = ['actor', 'page views', 'visits']
      
      stage :actor
      
      def setup
        super
        column_names = options.column_names || COLUMN_NAMES
        counts = options.counts || {}
        
        table = Table(column_names) do |t|
          counts.each do |count|
            t << [count.actor, count.visits, count.views]
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