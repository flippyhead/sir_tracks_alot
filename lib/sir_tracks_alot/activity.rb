module SirTracksAlot
  class Activity < Persistable
    include EventHelper
    extend FilterHelper 
    
    ACTIONS = [:create, :view, :login, :search, :update, :destroy]    
    LIMIT = 500

    attribute :created_at
    attribute :last_event # Clock.now
    attribute :owner      # 123123
    attribute :actor      # /users/peter-brown   
    attribute :target     # /discussions/23423
    attribute :category   # **automatically set**
    attribute :action     # create, view, login, etc.
    attribute :user_agent # IE/Safari Windows/Mac etc.
    attribute :counted    # true/false
    list      :events     # Clock.now's

    index :owner
    index :actor
    index :target
    index :category
    index :last_event
    index :action
    index :user_agent            
    index :counted     

    class <<self    
      alias_method :ohm_create, :create

      # Create with defaults: counted = 0
      def create(attrs)        
        ohm_create(attrs.merge(:counted => '0'))
      end
    end

    # find recent activities
    def self.recent(options_for_find, options_for_sort = {:order => 'DESC', :limit => LIMIT})
      find(options_for_find).sort_by(:last_event, options_for_sort)
    end              

    # Delete counted activities, leaving a default of the 500 most recent for the provided search criteria
    # If left blank, purges all but the most recent Limit
    def self.purge!(options_for_find = {}, options_for_sort = {:order => 'DESC'})
      recent(options_for_find.merge(:counted => 1), options_for_sort).each{|a| a.delete}
    end

    # set this activity to counted
    def counted!
      update(:counted => '1')
    end

    # is this activity counted?
    def counted?
      counted == '1'
    end    


    private

    def validate
      assert_present :owner
      assert_present :target
      assert_present :action
      assert_unique([:owner, :target, :action, :category, :user_agent, :actor])
    end

  end
end