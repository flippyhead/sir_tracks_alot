require File.dirname(__FILE__) + '/spec_helper.rb'

describe SirTracksAlot::Count do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset    
    @set_activities.each{|a| SirTracksAlot.record(a)}
  end  
  
  context 'when creating' do
    before do 
      @count_attributes = [{:owner => 'owner', :actor => '/users/user1', :target => '/categories/item1'}]
    end
    
    it 'should create valid count' do
      SirTracksAlot::Count.create(@count_attributes[0]).should be_valid
    end
    
    it 'should not validate duplicates' do
      SirTracksAlot::Count.create(@count_attributes[0])
      SirTracksAlot::Count.create(@count_attributes[0]).should_not be_valid
    end
    
    it "should have a to_hash with attributes" do
      SirTracksAlot::Count.create(@count_attributes[0]).to_hash.should == {:owner=>"owner", :target=>"/categories/item1", :id=>"1", :category=>nil, :actor=>"/users/user1"}
    end
  end
  
  context 'when filtering' do
    before do
      SirTracksAlot::Count.count(:owner => 'owner')
    end
    
    it "should build rows" do
      SirTracksAlot::Count.rows(:owner => 'owner').should == [["/categories", 1, 1], ["/categories/item1", 4, 4], ["/categories/item2", 1, 1], ["/other_categories", 2, 2], ["/other_categories/item", 2, 2]]
    end    
    
    it "should build rows with custom title" do
      SirTracksAlot::Count.rows({:owner => 'owner'}, 'title').should == [["title", 10, 10]]
    end
    
    it 'should filter by string attribute' do
      SirTracksAlot::Count.filter(:owner => 'owner').size.should == 5
    end
    
    it 'should filter by array of strings' do
      SirTracksAlot::Count.filter(:target => ['/categories', '/other_categories/item']).size.should == 2
    end

    it 'should include all targets when filtering just by ower' do
      SirTracksAlot::Count.filter(:owner => 'owner').collect{|c| c.target}.compact.sort.should == 
        ["/categories", "/categories/item1", "/categories/item2", "/other_categories", "/other_categories/item"].sort
    end

    it 'should include only filtered targets' do
      SirTracksAlot::Count.filter(:owner => 'owner', :target => ["/categories", "/categories/item1"]).collect{|c| c.target}.should_not
        include("/categories/item2")
    end    
  end
  
  context 'when summarizing' do
    before do
      SirTracksAlot::Count.count(:owner => 'owner')
    end
    
     it "should summarize daily counts" do
       SirTracksAlot::Count.summarize.should == {"2010/07/21"=>[2, 2], "2010/07/22"=>[8, 8]}
     end
     
     it "should summarize daily counts with find options" do
       SirTracksAlot::Count.summarize(:daily, :target => /.+/).should == {"2010/07/21"=>[2, 2], "2010/07/22"=>[8, 8]}
     end
     
     it "should summarize hourly counts" do
       SirTracksAlot::Count.summarize(:hourly).should == {"2010/07/21 17:00 UTC"=>[1, 1], "2010/07/21 20:00 UTC"=>[1, 1], "2010/07/22 01:00 UTC"=>[8, 8]}
     end
     
  end
  
  context 'when totalling' do
    before do 
      SirTracksAlot::Count.count(:owner => 'owner')
    end
        
    it "should total views and visits" do
      SirTracksAlot::Count.total([:views, :visits], :owner => 'owner').should == [10,10]
    end
  end
  
  context 'when counting hourly' do
    before do
      @counts = SirTracksAlot::Count.count(:owner => 'owner') 
    end    

    it "should set to counted all activities counted" do      
      SirTracksAlot::Count.count(:owner => 'owner')
      SirTracksAlot::Activity.filter(:counted => "0").should be_empty
    end
    
    it "should only count activities once" do
      SirTracksAlot::Count.count(:owner => 'owner', :category => ['categories'], :action => ['view']).should be_empty
    end    

    it "should include summaries" do
      @counts[0].summaries.size.should == 3
    end    
  end
  
  context 'when counting daily' do
    before do
      @counts = SirTracksAlot::Count.count({:owner => 'owner'}, {}, :daily) 
    end
    
    it "should count all activities for owner" do            
      SirTracksAlot::Count.find(:owner => 'owner').size.should == 5 # one for each unique target
    end
  end
end