require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Queue::ReportConfig do
  before do 
    RedisSpecHelper.reset
    @config = SirTracksAlot::Queue::ReportConfig.find_or_create(:owner => 'owner')
  end
  
  it "should build" do
    @config.should be_instance_of(SirTracksAlot::Queue::ReportConfig)
  end  
  
  it "should have default options" do
    @config.options.should be_instance_of(Hash)
  end
  
  it "should store options" do
    @config.options = {:this => 'that'}
    @config.options.should == {:this => 'that'}
  end
end