module SirTracksAlot
  module Reports
    class ActorReport < SirTracksAlotReport                
      COLUMN_NAMES = ['actor', 'page views', 'visits']
      
      stage :actor
      required_option :owner
      
      def setup
        super        
        counts = {}        
        options.column_names ||= COLUMN_NAMES
        options.actions ||= []
        options.roots ||= []
        
        options.roots.each do |root|
          options.actions.each do |action|            
            activities = Activity.find(:owner => options.owner, :action => action, :category => root)
            
            activities.each do |activity|
              counts[activity.actor] ||= [0,0]
              counts[activity.actor][0] += activity.views
              counts[activity.actor][1] += activity.visits(options.session_duration)
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
        renders :html, :for => ActorReport

        build :actor do
          output << erb((options.template || TRACKABLE_ROOT+"/views/reports/table.html.erb"), :binding => binding)
        end    
      end                  
    end
  end
end