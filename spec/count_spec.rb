require File.dirname(__FILE__) + '/spec_helper.rb'

describe SirTracksAlot::Count do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    
    @activities = [
      {:owner => 'owner', :target => '/categories/item1', :actor => '/users/user1', 
        :action => 'view', :user_agent => 'agent1', :event => 1279735846}, # 1.day.ago
        
      {:owner => 'owner', :target => '/categories/item1', :actor => '/users/user1', 
        :action => 'view', :user_agent => 'agent1', :event => 1279735846}, # 1.day.ago
        
      {:owner => 'owner', :target => '/categories/item1', :actor => '/users/user1', 
        :action => 'view', :user_agent => 'agent1', :event => 1279718578}, # 1.2.days.ago

      {:owner => 'owner', :target => '/categories/item1', :actor => '/users/user1', 
        :action => 'view', :user_agent => 'agent1', :event => 1279709941}, # 1.3.days.ago

      {:owner => 'owner', :target => '/categories/item2', :actor => '/users/user2', 
        :action => 'view', :user_agent => 'agent2', :event => 1279735846}, # 1.day.ago
        
      {:owner => 'owner', :target => '/categories', :actor => '/users/user2', 
        :action => 'view', :user_agent => 'agent2', :event => 1279735846}, # 1.day.ago
        
      {:owner => 'owner', :target => '/other_categories/item', :actor => '/users/user1', 
        :action => 'view', :user_agent => 'agent1', :event => (1279735846)}, # 1.day.ago
        
      {:owner => 'owner', :target => '/other_categories/item', :actor => '/users/user2', 
        :action => 'view', :user_agent => 'agent2', :event => 1279735846}, # 1.day.ago
        
      {:owner => 'owner', :target => '/other_categories', :actor => '/users/user1', 
        :action => 'view', :user_agent => 'agent1', :event => 1279735846}, # 1.day.ago
        
      {:owner => 'owner', :target => '/other_categories', :actor => '/users/user2', 
        :action => 'view', :user_agent => 'agent2', :event => 1279735846} # 1.day.ago
    ]
        
    @activities.each{|a| SirTracksAlot.record(a)}
  end  
  
  context 'when creating' do
    before do 
      @count_attributes = [{:owner => 'owner', :actor => '/users/user1', :target => '/categories/item1', :views => 1, :visits => 2, :date => '07/01/2010', :hour => 5}]
    end
    
    it 'should create valid count' do
      SirTracksAlot::Count.create(@count_attributes[0]).should be_valid
    end
    
    it 'should not validate duplicates' do
      SirTracksAlot::Count.create(@count_attributes[0])
      SirTracksAlot::Count.create(@count_attributes[0]).should_not be_valid
    end
  end
  
  context 'when counting' do
    before do
      @counts = SirTracksAlot::Count.count(OpenStruct.new(:owner => 'owner', :roots => ['categories'], :actions => ['view']))
    end
    
    it "should count all activities for owner" do      
      SirTracksAlot::Count.count(OpenStruct.new(:owner => 'owner')).size.should == 7 # one for each unique target, time combo
    end

    it "should count all activities for owner" do      
      SirTracksAlot::Count.count(OpenStruct.new(:owner => 'owner')).size.should == 7 # one for each unique target, time combo
    end
    
    context 'views' do    
      it "should include counts by hour" do
        @counts[0].hour.should == '18'        
      end
    
      it "should not include counts not requested" do
        @counts.collect{|c| c.target}.should_not include("/other_categories") 
      end
    end
    
    context 'visits' do
      it 'should include counts by hour' do
        # @counts[1].should == {"/categories"=>{"2010/07/21 18"=>1}, 
        #   "/categories/item1"=>{"2010/07/21 18"=>2, "2010/07/21 10"=>1, "2010/07/21 13"=>1}, 
        #   "/categories/item2"=>{"2010/07/21 18"=>1}}
      end
    end    
  end
end