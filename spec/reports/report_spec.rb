require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Reports::Report do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @activities.each{|a| SirTracksAlot.record(a)}
    SirTracksAlot::Count.count(:owner => 'owner')
  end    
  
  it "should " do
    SirTracksAlot::Reports::Report.build_rows([{:owner => 'owner'}]).should == [["/categories", 1, 1], ["/categories/item1", 1, 1], 
      ["/users/user1", 3, 3], ["/categories/item2", 1, 1], ["/other_categories", 2, 2], ["/other_categories/item", 2, 2], ["/users/user2", 4, 4]]
  end
end
