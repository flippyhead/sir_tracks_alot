module SirTracksAlot
  module Reports
    class FilterReport < SirTracksAlotReport      
      COLUMN_NAMES = ['title', 'page views', 'visits']
      
      stage :base      
      required_option :owner      
      
      # Build up reports by filtering things. Filters are applied and assigned a row title.
      #
      # :filters = {
      #   'Title' => {:category => 'category', :target => /\/categories/}
      # }
      #      
      def setup
        super
        
        counts = {}
        options.filters ||= {}
        options.column_names ||= COLUMN_NAMES
        
        options.filters.each do |title, options_for_find|
          Count.filter(options_for_find.merge(:owner => options.owner)).each do |count|
            count.summaries.each do |summary|
              counts[title] ||= [0,0]
              counts[title][0] += summary.visits.to_i
              counts[title][1] += summary.views.to_i
            end
          end
        end
      
        table = Table(options.column_names) do |t|
          counts.each do |title, n|
            t << [title, n[0], n[1]]
          end
        end
        
        table.sort_rows_by!('page views', :order => :descending)
        
        self.data = table
      end
            
      module Helpers
        include Report::Helpers
      end

      class HTML < Ruport::Formatter::HTML    
        renders :html, :for => FilterReport

        build :base do
          output << erb(options.template || TRACKABLE_ROOT+"/views/reports/table.html.erb", :binding => binding)
        end    
      end      
    end
  end
end