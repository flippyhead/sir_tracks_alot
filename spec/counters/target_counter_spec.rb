require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Counters::TargetCounter do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @activities.each{|a| SirTracksAlot.record(a)}
    @mock_finder = mock('Finder', :find => [], :collect => [])
    @mock_filter = mock('Filter', :each => [])
    @count_options = OpenStruct.new(@report_attributes)
  end  
  
  # it "should find activities when building data" do
  #   SirTracksAlot::Activity.should_receive(:filter).with(
  #     :action => @activities[0][:action], :owner => @activities[0][:owner], :target => nil, :category=>"categories").exactly(1).times.and_return(@mock_filter)
  #   SirTracksAlot::Counters::TargetCounter.count(@count_options)
  # end
  # 
  # it "should build hash of counts" do
  #   SirTracksAlot::Counters::TargetCounter.count(@count_options).should == @counts
  # end
  
end