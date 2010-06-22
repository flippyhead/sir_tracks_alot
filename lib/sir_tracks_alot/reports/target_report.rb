module SirTracksAlot
  module Reports
    class TargetReport < SirTracksAlotReport
      COLUMN_NAMES = ['target', 'page views', 'visits']
      
      stage :target      
      required_option :owner, :actions
      
      def setup
        super
        counts = {}
        options.filters ||= false
        options.column_names ||= COLUMN_NAMES
        options.actions ||= []
        options.roots ||= []
        
        options.roots.each do |root|
          options.actions.each do |action|
            activities = Activity.filter(:owner => options.owner, :target => options.target, :action => action, :category => root)

            activities.each do |activity|              
              counts[activity.target] ||= [0,0]
              counts[activity.target][0] += activity.views
              counts[activity.target][1] += activity.visits(options.session_duration)
            end                      
          end
        end
        
        table = Table(options.column_names) do |t|
          counts.each do |target, count|
            t << [target, count[0], count[1]]
          end
        end
        
        table.sort_rows_by!('page views', :order => :descending)
        
        self.data = table
      end  
                  
      module Helpers
        include Report::Helpers        
      end


      class HTML < Ruport::Formatter::HTML
        renders :html, :for => TargetReport

        build :target do
          output << erb((options.template || TRACKABLE_ROOT+"/views/reports/table.html.erb"), :binding => binding)
        end    
      end                  
    end
  end
end