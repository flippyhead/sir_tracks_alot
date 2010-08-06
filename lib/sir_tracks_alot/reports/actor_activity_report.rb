module SirTracksAlot
  module Reports
    class ActorActivityReport < SirTracksAlotReport
      COLUMN_NAMES = ['target', 'page views', 'visits']
      
      stage :main
      required_option :owner, :actor
      
      def setup
        super
        counts = {}
        options.column_names ||= COLUMN_NAMES
        
        activities = Activity.find(:owner => options.owner, :actor => options.actor)
        
        activities.each do |activity|
          counts[activity.target] ||= [0,0]
          counts[activity.target][0] += activity.views
          counts[activity.target][1] += activity.visits(options.session_duration)          
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
        renders :html, :for => ActorActivityReport

        build :main do
          output << erb((options.template || TRACKABLE_ROOT+"/views/reports/table.html.erb"), :binding => binding)
        end    
      end                  
    end
  end
end