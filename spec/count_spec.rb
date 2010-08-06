require File.dirname(__FILE__) + '/spec_helper.rb'

describe SirTracksAlot::Count do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset    
    @set_activities.each{|a| SirTracksAlot.record(a)}
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
    
    it "should have a to_hash with attributes" do
      SirTracksAlot::Count.create(@count_attributes[0]).to_hash.should ==  {:owner=>"owner", :views=>1, :visits=>2, :hour=>5, :target=>"/categories/item1", :id=>"1", :date=>"07/01/2010", :category=>nil, :actor=>"/users/user1"}
    end
  end
  
  context 'when filtering' do
    before do
      SirTracksAlot::Count.count(:owner => 'owner')
    end
    
    it 'should filter by string attribute' do
      SirTracksAlot::Count.filter(:owner => 'owner').size.should == 13
    end
    
    it 'should filter by array of strings' do
      SirTracksAlot::Count.filter(:target => ['/categories', '/other_categories/item']).size.should == 2
    end

    it 'should include all targets when filtering just by ower' do
      SirTracksAlot::Count.filter(:owner => 'owner').collect{|c| c.target}.compact.sort.should == 
        ["/categories", "/categories/item1", "/categories/item1", "/categories/item1", "/categories/item2", "/other_categories", "/other_categories/item"].sort
    end

    it 'should include only filtered targets' do
      SirTracksAlot::Count.filter(:owner => 'owner', :target => ["/categories", "/categories/item1"]).collect{|c| c.target}.should_not
        include("/categories/item2")
    end    
  end
  
  context 'when totalling' do
    before do 
      @mock_activity = mock(SirTracksAlot::Activity, :visits => 1, :views => 2)
      SirTracksAlot::Count.stub!(:filter => [@mock_activity])
    end
    
    it "should look for activities using find options" do
      SirTracksAlot::Count.should_receive(:filter).with(:owner => 'owner').and_return([@mock_activity])
      SirTracksAlot::Count.total(:views, :owner => 'owner')
    end
    
    # it "should look for views when counting views" do
    #   @mock_activity.should_receive(:views).once.and_return(1)
    #   SirTracksAlot::Count.total(:views, :owner => 'owner')
    # end    
    # 
    # it "should not look for views when counting visits" do
    #   @mock_activity.should_receive(:views).never
    #   SirTracksAlot::Activity.count(:visits, :owner => 'owner')
    # end
    # 
    # it "should return views and visits" do            
    #   SirTracksAlot::Activity.count([:visits, :views], :owner => 'owner').should == [1,2]
    # end
    # 
    # it "should return visits" do    
    #   SirTracksAlot::Activity.count([:visits], :owner => 'owner').should == 1
    # end
    # 
    # it "should ignore empty only" do
    #   SirTracksAlot::Activity.count([:visits], :owner => 'owner', :only => {}).should == 1      
    # end
    # 
    # it "should filter by category" do
    #   @mock_activity.should_receive(:category).once.and_return('category')
    #   SirTracksAlot::Activity.count([:visits], :owner => 'owner', :category => /category/)
    # end
    # 
    # it "should filter by category and match returning correct count" do
    #   @mock_activity.stub!(:category => 'category')
    #   SirTracksAlot::Activity.count([:visits], :owner => 'owner', :category => /category/).should == 1      
    # end
  end
  
  context 'when counting' do
    before do
      @counts = SirTracksAlot::Count.count(:owner => 'owner', :category => ['categories'], :action => ['view'])
    end
    
    it "should count all activities for owner" do      
      SirTracksAlot::Count.count(:owner => 'owner')
      SirTracksAlot::Count.find(:owner => 'owner').size.should == 13 # one for each unique target, time combo
    end

    it "should set to counted all activities counted" do      
      SirTracksAlot::Count.count(:owner => 'owner')
      SirTracksAlot::Activity.filter(:counted => "0").should be_empty
    end
    
    it "should only count activities once" do
      SirTracksAlot::Count.count(:owner => 'owner', :category => ['categories'], :action => ['view']).should be_empty
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