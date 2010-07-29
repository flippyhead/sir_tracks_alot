module SirTracksAlot
  class Count < Persistable
    ACTIONS = [:create, :view, :login, :search, :update, :destroy]
    
    attribute :date       # 10/01/2010
    attribute :hour       # 1 - 23
    attribute :owner      # 123123
    attribute :actor      # /users/peter-brown   
    attribute :target     # /discussions/23423
    attribute :category   # **automatically set**
    attribute :views
    attribute :visits
    
    index :date
    index :hour
    index :owner
    index :actor
    index :target
    index :category


    def self.count(options)
      counts = {}
      actions = options.actions || []
      roots = options.roots || []
      owner = options.owner
      target = options.target
      
      activities = Activity.filter(:owner => owner, :target => target, :action => actions, :category => roots)

      activities.each do |activity|
        activity.views(:hourly).each do |time, count|
          date, hour = time.split(' ')
          
          counts[activity.target] ||= {}
          counts[activity.target][time] ||= Count.new(:owner => owner, :target => activity.target, :views => 0, :visits => 0, :date => date, :hour => hour)
          counts[activity.target][time].views += count
        end
        
        activity.visits(options.session_duration, :hourly).each do |time, count|
          date, hour = time.split(' ')
          
          counts[activity.target] ||= {}
          counts[activity.target][time] ||= Count.new(:owner => owner, :target => activity.target, :views => 0, :visits => 0, :date => date, :hour => hour)
          counts[activity.target][time].visits += count
        end
      end
      
      counts.each do |target, groups|
        groups.each do |time, count|
          count.save
        end
      end

      counts.values.collect{|v| v.values}.flatten
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