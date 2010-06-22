require File.dirname(__FILE__) + '/spec_helper.rb'

describe SirTracksAlot, 'when recording' do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @record_attributes = @activities[0]
  end  
  
  it "should record activity" do
    activity = SirTracksAlot.record(@record_attributes)
    activity.should be_valid
  end  
  
  it "should raise RecordInvalidError on invalid record" do
    lambda {SirTracksAlot.record({})}.should 
      raise_error(SirTracksAlot::RecordInvalidError, 
        'Activity not valid: [[:target, :not_present], [:category, :not_present], [:action, :not_present]]')
  end
  
  it "should be created" do
    SirTracksAlot.record(@record_attributes)
    activities = SirTracksAlot::Activity.find(:target => @record_attributes[:target])
    activities.size.should == 1
  end  
  
  it "should be created once" do
    SirTracksAlot.record(@record_attributes)
    SirTracksAlot.record(@record_attributes)
    activities = SirTracksAlot::Activity.all
    activities.size.should == 1
  end      
  
  it "should have correct date count" do
    SirTracksAlot.record(@record_attributes)
    SirTracksAlot.record(@record_attributes)    
    activity = SirTracksAlot::Activity.all.first
    activity.events.size.should == 2
  end  

  it "should have events" do
    SirTracksAlot::Clock.stub!(:now).and_return('123')
    activity = SirTracksAlot.record(@record_attributes)
    activity = SirTracksAlot::Activity.all.first    
    activity.events.first.should == '123'
  end      
  
  it "should have last_event set to most recent event" do
    SirTracksAlot::Clock.stub!(:now).and_return('123')
    activity = SirTracksAlot.record(@record_attributes)
    activity = SirTracksAlot::Activity.all.first    
    activity.last_event.should == '123'    
  end
  
  it "should add date for now" do
    SirTracksAlot::Clock.should_receive(:now).twice # once for activity create, once for events date
    SirTracksAlot.record(@record_attributes)
  end

  it "should add custom event if provided" do
    SirTracksAlot::Clock.should_receive(:now).once # only for activity create, not for events date
    SirTracksAlot.record(@record_attributes.merge(:event => Time.now.utc.to_i))
  end
  
  it "should use to_trackable_id if present" do    
    target_mock = mock('Target')
    target_mock.should_receive(:respond_to?).with(:to_trackable_id).and_return(true)
    target_mock.should_receive(:to_trackable_id).and_return('target')    
    SirTracksAlot.record(@record_attributes.merge(:target => target_mock))
  end
  
  it "should use extract category" do        
    target_mock = mock('Target')    
    target_mock.stub!(:respond_to?).with(:to_trackable_id).and_return(true)
    target_mock.stub!(:to_trackable_id).and_return('/target')    
    
    activity = SirTracksAlot.record(@record_attributes.merge(:target => target_mock))
    activity.category.should == 'target'
  end  
  
  context 'filter activities' do    
    before do 
      SirTracksAlot.exclude(:user_agent => /agent2/)
      @activities.each{|a| SirTracksAlot.record(a)}      
    end
    
    it "should include unfiltered activities" do      
      SirTracksAlot::Activity.find(:user_agent => 'agent1').should_not be_empty            
    end
    
    it "should not include filtered activities" do      
      SirTracksAlot::Activity.find(:user_agent => 'agent2').should be_empty            
    end    
    
    after do 
      SirTracksAlot.clear!
    end
  end
end

