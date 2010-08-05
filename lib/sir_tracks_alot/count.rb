module SirTracksAlot
  class Count < Persistable
    extend FilterHelper
    
    ACTIONS = [:create, :view, :login, :search, :update, :destroy]
    
    attribute :created_at 
    attribute :date       # 10/01/2010
    attribute :hour       # 1 - 23
    attribute :owner      # 123123
    attribute :actor      # /users/peter-brown   
    attribute :target     # /discussions/23423
    attribute :category   
    attribute :views
    attribute :visits
    
    index :date
    index :hour
    index :owner
    index :actor
    index :target
    index :category

    # def self.count(what, options_for_find)      
    #   what = [what] unless what.kind_of?(Array)      
    #   views, visits = 0, 0      
    #   session_duration = options_for_find.delete(:session_duration)
    #   resolution = options_for_find.delete(:resolution)
    #   
    #   filter(options_for_find) do |activity|
    #     views += activity.views(resolution) if what.include?(:views)
    #     visits += activity.visits(session_duration) if what.include?(:visits)
    #   en+d      
    #         
    #   return [views, visits] if what == [:views, :visits]
    #   return [visits, views] if what == [:visits, :views]
    #   return views if what == [:views]
    #   return visits if what == [:visits]
    #   raise ArgumentError("what must be one or more of :views, :visits")
    # end        

    def self.total(what, options_for_find)
      what = [what] unless what.kind_of?(Array)      
      views, visits = 0, 0      

      filter(options_for_find) do |count|
        views +=  count.views.to_i if what.include?(:views)
        visits += count.visits.to_i if what.include?(:visits)
      end      

      return [views, visits] if what == [:views, :visits]
      return [visits, views] if what == [:visits, :views]
      return views if what == [:views]
      return visits if what == [:visits]
      raise ArgumentError("what must be one or more of :views, :visits")      
    end

    def self.count(options)
      options = OpenStruct.new(options) if options.kind_of?(Hash)
      
      rollup(Activity.filter(:owner => options.owner, 
          :target => options.target, 
          :action => options.action||[], 
          :category => options.category || [], 
          :counted => '0'), 
        options.session_duration
      )
    end
    
    def self.rollup(activities, session_duration)
      counts = []

      activities.each do |activity|        
        activity.views(:hourly).each do |time, views|          
          date, hour = time.split(' ')
          counts << create_by_activity({:owner => activity.owner, :category => activity.category, :target => activity.target, :date => date, :hour => hour}, views, 0)
          counts << create_by_activity({:owner => activity.owner, :category => activity.category, :actor => activity.actor, :date => date, :hour => hour}, views, 0)
        end

        activity.visits(session_duration, :hourly).each do |time, visits|
          date, hour = time.split(' ')
          counts << create_by_activity({:owner => activity.owner, :category => activity.category, :target => activity.target, :date => date, :hour => hour}, 0, visits)
          counts << create_by_activity({:owner => activity.owner, :category => activity.category, :actor => activity.actor, :date => date, :hour => hour}, 0, visits)
        end

        activity.counted!        
      end
      
      counts
    end
    
    def self.create_by_activity(attributes, views = 0, visits = 0)
      count = Count.find_or_create(attributes)
        
      count.views ||= 0; count.visits ||= 0

      count.views  = count.views.to_i + views 
      count.visits = count.visits.to_i + visits
      
      count.save        
    end
    
            
    private

    def validate
      assert_present :owner
      assert_present :views
      assert_present :visits
      assert_unique([:owner, :actor, :target, :category, :date, :hour])
    end
    
  end
end