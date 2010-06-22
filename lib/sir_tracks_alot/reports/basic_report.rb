module SirTracksAlot
  module Reports
    class BasicReport < Report
      COLUMN_NAMES = ['group', 'title', 'count']
      stage :basic
      
      def setup      
        options.column_names ||= COLUMN_NAMES          
        
        table = Table(options.column_names, :data => options.data)
        grouping = Grouping(table, :by => "group", :order => 'group')
        grouping.each{|n, g| g.sort_rows_by!('count', :order => :descending)}

        self.data = grouping
      end  
                  
      module Helpers
        include Report::Helpers
      end

      class HTML < Ruport::Formatter::HTML
        renders :html, :for => BasicReport        

        build :basic do
          output << erb((options.template || TRACKABLE_ROOT+"/views/reports/group.html.erb"), :binding => binding)
        end    
      end                  
    end
  end
end