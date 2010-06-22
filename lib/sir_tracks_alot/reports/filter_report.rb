module SirTracksAlot
  module Reports
    class FilterReport < SirTracksAlotReport      
      COLUMN_NAMES = ['title', 'page views', 'visits']
      
      stage :base      
      required_option :owner      
      
      # Build up reports by filtering things. Filters are applied and assigned a row title.
      #
      # SirTracksAlot::Reports::FilterReport.render_html(
      #   :actions => ['view', 'search']
      # 
      # :filters = {
      #   'Title' => {:category => 'category', :target => /\/categories/}
      # }
      #      
      # :filters => {
      #   :only => {Profile Pages' => {:target => /^\/user_profiles\/.+$/}}
      #   :except => {Profile Index' => {:target => /^\/user_profiles$/}}
      # })      
      def setup
        super
        
        counts = []
        options.filters ||= {}
        options.column_names ||= COLUMN_NAMES
                
        options.filters.each do |title, options_for_find|          
          views, visits = Activity.count([:views, :visits], options_for_find.merge(:owner => options.owner))          
          counts << [title, views, visits] if views > 0
        end
        
        
        table = Table(options.column_names, :data => counts)

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