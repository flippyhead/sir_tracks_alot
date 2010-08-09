module SirTracksAlot
  module Reports
    class SimpleReport < Report
      COLUMN_NAMES = ['target', 'page views', 'visits']
      
      stage :simple
      
      def setup      
        options.column_names ||= COLUMN_NAMES
        
        rows = Report.build_rows(options.filters)
        
        table = Table(options.column_names, :data => rows)
        
        if options.group
          grouping = Grouping(table, :by => options.group, :order => options.group)
          grouping.each{|n, g| g.sort_rows_by!('count', :order => :descending)}
          self.data = grouping
        else
          table.sort_rows_by!('page views', :order => :descending)        
          self.data = table
        end

      end

      module Helpers
        include Report::Helpers
      end

      class HTML < Ruport::Formatter::HTML
        renders :html, :for => SimpleReport        

        build :simple do
          if options.group
            output << erb((options.template || TRACKABLE_ROOT+"/views/reports/group.html.erb"), :binding => binding)
          else
            output << erb((options.template || TRACKABLE_ROOT+"/views/reports/table.html.erb"), :binding => binding)
          end
        end    
      end                  
    end
  end
end