module SirTracksAlot
  class Count < Persistable
    extend FilterHelper
    
    ACTIONS = [:create, :view, :login, :search, :update, :destroy]
    
    attribute :created_at 
    attribute :owner      # 123123
    attribute :actor      # /users/peter-brown   
    attribute :target     # /discussions/23423
    attribute :category   # /discussions    
    attribute :action     # create
    set       :summaries, Summary    
    
    index :owner
    index :actor
    index :target
    index :category
    index :action

    def self.total(what, options_for_find)
      what = [what] unless what.kind_of?(Array)      
      views, visits = 0, 0

      filter(options_for_find).each do |count|
        count.summaries.each do |summary|
          views +=  summary.views.to_i if what.include?(:views)
          visits += summary.visits.to_i if what.include?(:visits)
        end
      end      

      return [views, visits] if what == [:views, :visits]
      return [visits, views] if what == [:visits, :views]
      return views if what == [:views]
      return visits if what == [:visits]
      raise ArgumentError("what must be one or both of :views, :visits")      
    end
    
    def self.rows(options_for_find, title = nil)
      groups = {}
      
      filter(options_for_find).each do |count|
        t = title || count.target || count.actor # don't currently support counts with both actor and target set
        
        count.summaries.each do |summary|
          groups[t] ||= [0,0]
          groups[t][0] += summary.views.to_i
          groups[t][1] += summary.visits.to_i
        end
      end
      
      groups.collect{|g| g.flatten}
    end

    # Convert a default of 500 activities into counts
    def self.count(options_for_find = {}, options_for_sort = {:limit => 500}, resolution = :hourly)
      options_for_find = options_for_find.to_hash
      session_duration = options_for_find.delete(:session_duration)
      activities = Activity.find(options_for_find.merge(:counted => 0, :action => [], :category => [])).sort(options_for_sort)
      rollup(activities, session_duration, resolution)
    end
    
    # Summarize counts daily or hourly
    # All times are in UTC
    def self.summarize(resolution = :daily, options_for_find = {})
      counts = {}

      filter(options_for_find).each do |count|
        count.summaries.each do |summary|          
          key = case resolution
            when :daily
              Time.at(summary.date).utc.strftime('%Y/%m/%d')
            when :hourly
              Time.at(summary.date).utc.strftime('%Y/%m/%d %H:00 UTC')
            end
        
          counts[key]   ||= [0,0]
          counts[key][0] += summary.views.to_i
          counts[key][1] += summary.visits.to_i
        end
      end
      
      counts
    end
    
    # Rollup all activities by resolution
    # Create one count for actor and one count for target
    def self.rollup(activities, session_duration, resolution = :hourly)
      counts = []

      activities.each do |activity|        
        count = Count.find_or_create(:owner => activity.owner, :category => activity.category,  :target => activity.target, :action => activity.action)
      
        activity.views(resolution).each do |time, views|
          date = Time.parse(time).to_i
          summary = count.summaries.find(:date => date).first || Summary.create(:date => date)
          summary.update(:views => views)                    
        end

        activity.visits(session_duration, resolution).each do |time, visits|
          date = Time.parse(time).to_i          
          summary = count.summaries.find(:date => date).first || Summary.create(:date => date)
          summary.update(:views => visits)                              
        end

        activity.counted!        
      end
      
      counts
    end
    
    def to_hash
      {:owner => owner, :actor => actor, :target => target, :category => category, :id => id}
    end    


    private

    def validate
      assert_present :owner
      assert_unique([:owner, :actor, :target, :category, :action])
    end
    
  end
end