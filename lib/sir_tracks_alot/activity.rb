module SirTracksAlot
  class Activity < Persistable
    ACTIONS = [:create, :view, :login, :search, :update, :destroy]
    DATE_FORMATS = {:hourly => '%Y/%m/%d %H', :daily => '%Y/%m/%d'}
    LIMIT = 1000
    
    attribute :created_at
    attribute :last_event # Clock.now
    attribute :owner      # 123123
    attribute :actor      # /users/peter-brown   
    attribute :target     # /discussions/23423
    attribute :category   # **automatically set**
    attribute :action     # create, view, login, etc.
    attribute :user_agent # IE/Safari Windows/Mac etc.
    list      :events     # Clock.now's
    
    index :owner
    index :actor
    index :target
    index :category
    index :last_event
    index :action
    index :user_agent    
        
    # Find activities that match attributes 
    # Strings are passed to Ohm
    # Regular Expression filters match against retrieved attribute values
    # 
    # filter(:actor => 'user1', :target => /\/targets\/\d+/, :action => ['view', 'create'], :category => ['/root', '/other_root'])
    def self.filter(options_for_find, &block)      
      activities = []
      # sort = options_for_find.delete(:sort) || {}
      all = []
      
      strings = {}
      matchers = {}
      arrays = {}
      
      options_for_find.each do |key, candidate|
        matchers[key] = candidate if candidate.kind_of?(Regexp) && !candidate.blank?
        strings[key]  = candidate if candidate.kind_of?(String) && !candidate.blank?
        arrays[key]   = candidate if candidate.kind_of?(Array)  && !candidate.blank?
      end
      
      unless arrays.empty?
        (arrays.values.inject{|a, b| a.product b}).each do |combo|
          terms = {}; combo.each{|c| terms[find_key_from_value(arrays, c)] = c}
          all += SirTracksAlot::Activity.find(terms.merge(strings)).to_a
        end
      else
        all = SirTracksAlot::Activity.find(strings).to_a
      end

      all.each do |activity|
        pass = true
        
        matchers.each do |key, matcher|
          pass = false if !matcher.match(activity.send(key))
        end

        next unless pass
        
        yield activity if block_given?
        
        activities << activity
      end
      
      activities      
    end
      
    # resolution can be: hourly = %Y/%m/%d %H, daily = %Y/%m/%d or any valid strftime string
    def self.count_by(resolution, options_for_find = {})      
      groups = {}
      
      filter(options_for_find) do |activity|
        activity.views(resolution).each do |time, count| 
          groups[time] ||= 0
          groups[time] += count
        end
      end
      
      groups
    end
    
    def self.recent(options_for_find, options_for_sort = {:order => 'DESC', :limit => LIMIT})
      SirTracksAlot::Activity.find(options_for_find).sort_by(:last_event, options_for_sort)
    end      
        
    def self.count(what, options_for_find)      
      what = [what] unless what.kind_of?(Array)      
      views, visits = 0, 0      
      session_duration = options_for_find.delete(:session_duration)
      resolution = options_for_find.delete(:resolution)
      
      filter(options_for_find) do |activity|
        views += activity.views(resolution) if what.include?(:views)
        visits += activity.visits(session_duration) if what.include?(:visits)
      end      
            
      return [views, visits] if what == [:views, :visits]
      return [visits, views] if what == [:visits, :views]
      return views if what == [:views]
      return visits if what == [:visits]
      raise ArgumentError("what must be one or more of :views, :visits")
    end        
        
    def views(resolution = nil)
      return events.size if resolution.nil?
            
      groups = {}
      
      date_format = resolution.kind_of?(String) ? resolution : DATE_FORMATS[resolution]

      events.each do |event|      
        time = Time.at(event.to_i).utc.strftime(date_format) # lop of some detail
        groups[time.to_s] ||= 0
        groups[time.to_s] += 1 
      end
      
      return groups
    end
    
    # Count one visit for all events every session_duration (in seconds)
    # e.g. 3 visits within 15 minutes counts as one, 1 visit 2 days later counts as another
    def visits(sd = 1800, resolution = nil)
      session_duration = sd || 1800      
      last_event = events.first
      
      count = events.size > 0 ? 1 : 0 # in case last_event == event (below)
      groups = {}
      
      events.each do |event|
        boundary = (event.to_i - last_event.to_i > session_duration) # have we crossed a session boundary?
        
        if resolution.nil? # i.e. don't group
          count += 1 if boundary
        else
          date_format = resolution.kind_of?(String) ? resolution : DATE_FORMATS[resolution]
          time = Time.at(event.to_i).utc.strftime(date_format) # lop of some detail
          
          groups[time.to_s] ||= count
          groups[time.to_s] += 1 if boundary
        end
        
        last_event = event # try the next bounary
      end

      resolution.nil? ? count : groups
    end


    private
    
    def self.find_key_from_value(hash, value)
      hash.each do |k, v|
        return k if v.include?(value)
      end
    end
    
    def validate
      assert_present :owner
      assert_present :target
      assert_present :action
      assert_unique([:owner, :target, :action, :category, :user_agent, :actor])
    end
    
  end
end