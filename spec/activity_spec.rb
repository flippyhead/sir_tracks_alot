require File.dirname(__FILE__) + '/spec_helper.rb'

describe SirTracksAlot::Activity do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @now = SirTracksAlot::Clock.now
    @activity = SirTracksAlot::Activity.create(@activities[0])
    @activity.events << @now
    @activity.update(:last_event => @now)
  end  
  
  context 'when creating' do
    it "should store valid activities" do
      @activity.should be_valid
    end
  
    it "should not store invalid activities" do
      activity = SirTracksAlot::Activity.create({})
      activity.should_not be_valid
    end
    
    it "should not validate duplicates" do
      activity = SirTracksAlot::Activity.create(@activities[0]) # already created in before
      activity.should_not be_valid
    end
    
    it "should set counted" do
      @activity.counted!
      @activity.should be_counted
    end
    
    it "should default to uncounted" do
      @activity.counted.should == '0'
    end
  end
  
  context 'when purging' do
    before do
      @activities.each{|a| SirTracksAlot.record(a)}
    end
    
    it "should not purge uncounted" do
      SirTracksAlot::Activity.purge!
      SirTracksAlot::Activity.all.size.should == 8
    end        
    
    it "should purge counted, not touching first 500 (by default)" do
      SirTracksAlot::Activity.all.each{|a| a.counted!}
      SirTracksAlot::Activity.purge!()
      SirTracksAlot::Activity.all.size.should == 8
    end
    
    it "should purge counted by range" do
      SirTracksAlot::Activity.all.each{|a| a.counted!}
      SirTracksAlot::Activity.purge!({}, :start => 5, :limit => 10)
      SirTracksAlot::Activity.all.size.should == 5
    end
  end
  
  context 'when filtering (simple)' do
    before do 
      @mock_activity = mock(SirTracksAlot::Activity, @activities[0])
      SirTracksAlot::Activity.stub!(:find => [@mock_activity])
    end
    
    it "should find activities matching attribute regex" do
      SirTracksAlot::Activity.filter(:owner => 'owner', :target => /categories/).size.should == 1
    end
  
    it "should find activities matching attribute string" do
      SirTracksAlot::Activity.filter(:owner => 'owner', :category => 'category').size.should == 1
    end
  
    it "should find activities matching attribute string and attribute regex" do
      SirTracksAlot::Activity.filter(:owner => 'owner', :category => 'category', :target => /categories/).size.should == 1
    end
  
    it "should not find activities matching attribute string but not attribute regex" do
      SirTracksAlot::Activity.filter(:owner => 'owner', :category => 'category', :target => /not_there/).size.should == 0
    end
    
    it "should not match with negative regex" do
      SirTracksAlot::Activity.filter(:owner => /^(?!(.*owner.*))/).size.should == 0
    end        
  end
  
  context 'when filtering (many)' do
    before do 
      @activities.each{|a| SirTracksAlot.record(a)}
    end
    
    it "should filter by members which are regex's" do 
      # SirTracksAlot::Activity.filter(:owner => 'owner', :target => [/categories/, /\/categories\//]).size.should == 3
    end    

    it "should filter by members of one array" do
      SirTracksAlot::Activity.filter(:owner => 'owner', :target => ['/categories/item1', '/categories/item2']).size.should == 3 
    end    
    
    it "should filter by combinations of arrays" do
      SirTracksAlot::Activity.filter(:owner => 'owner', :action => ['view', 'create'], :target => ['/categories/item1', '/categories/item2']).size.should == 3
    end    
  end
  
  context 'when getting recent' do
    before do 
      @set_activities.each{|a| SirTracksAlot.record(a)} 
    end
    
    it "should get recent" do
      SirTracksAlot::Activity.recent(:owner => 'owner').should be_instance_of(Array)
    end
    
    it "should purge counted by range, sorting to most recent by last event" do
      SirTracksAlot::Activity.recent(:owner => 'owner').first.last_event.should == @now.to_s
    end            
    
    it "should purge counted by range, sorting to most recent by last event" do
      SirTracksAlot::Activity.recent({:owner => 'owner'}, :start => 1).first.last_event.should == '1279709941'
    end                
  end  
  
  context 'when counting views' do
    before do
      # nothing
    end
    
    it "should try to parse event time" do      
      time = Time.at(@now)
      Time.should_receive(:at).with(@now).and_return(time)
      @activity.views(:daily)
    end
    
    it "should return grouped counts" do
      @activity.views(:daily).should be_kind_of(Hash)      
    end
  
    it "should return count as hash value" do
      @activity.views(:daily).values.should == [1]
    end
  
    it "should return count key'd by date" do
      key = Time.at(@now).utc.strftime(SirTracksAlot::Activity::DATE_FORMATS[:daily])
      @activity.views(:daily).keys.should == [key]
    end    
    
    it "should return count multiple for single group" do
      SirTracksAlot::Activity.all.first.events << @now
      @activity.views(:daily).values.should == [2]
    end    
  end
  
  context 'when calculating visits' do
    it "should count 2 visits within the duration as one visit" do
      2.times{@activity.events << SirTracksAlot::Clock.now}
      @activity.visits.should == 1
    end
    
    it "should count 200 visits within the duration as one visit" do
      200.times{@activity.events << SirTracksAlot::Clock.now}
      @activity.visits.should == 1
    end
  
    it "should count 2 visits separated by greater than default session duration as 2 visits" do
      @activity.events << SirTracksAlot::Clock.now 
      @activity.events << SirTracksAlot::Clock.now + 2000
      @activity.visits.should == 2
    end
  
    it "should count 2 visits separated by greater than default session duration as 2, and a 3rd" do
      5.times{@activity.events << SirTracksAlot::Clock.now}
      @activity.events << SirTracksAlot::Clock.now + 2000
      @activity.events << SirTracksAlot::Clock.now + 4000
      @activity.visits.should == 3
    end
    
    it "should group separated visits hourly" do
      5.times{@activity.events << 1279735846}
      @activity.events         << 1279709941      
      # @activity.visits(1800, :hourly).should == {"2010/07/27 20"=>1, "2010/07/27 21"=>2}
    end
        
  end
  
end

