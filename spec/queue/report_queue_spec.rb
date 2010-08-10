require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Queue::ReportQueue do
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @queue = SirTracksAlot::Queue::ReportQueue.find_or_create(:name => 'queue')
  end
  
  it "should build" do
    @queue.should be_instance_of(SirTracksAlot::Queue::ReportQueue)
  end    
  
  context 'when pushing' do  
    before do
      @config = mock(SirTracksAlot::Queue::ReportConfig, :options => {}, :options= => true, :id => 1)
      @activities.each{|a| SirTracksAlot.record(a)}
      SirTracksAlot::Queue::ReportQueue.push('owner', :actor_report, {})      
    end
  
    it "should create a new queue" do      
      SirTracksAlot::Queue::ReportQueue.should_receive(:find_or_create).with(:name => SirTracksAlot::Queue::ReportQueue::QUEUE_NAME).and_return(@queue)
      SirTracksAlot::Queue::ReportQueue.push('owner', 'report', {})
    end    
    
    it "should create report config" do
      SirTracksAlot::Queue::ReportConfig.should_receive(:find_or_create).with(:owner => 'owner', :report => 'report').once.and_return(@config)
      SirTracksAlot::Queue::ReportQueue.push('owner', 'report', {})
    end    
  end
  
  context 'when popping' do
    before do      
      @cache = mock(SirTracksAlot::Queue::ReportCache, :update => true)      
      @activities.each{|a| SirTracksAlot.record(a)}
      SirTracksAlot::Queue::ReportQueue.push('owner', :target_report, {:filters => {:category => ['categories', 'other_categories']}})
    end
    
    it "should find existing queue" do
      SirTracksAlot::Queue::ReportQueue.should_receive(:find).with(:name => SirTracksAlot::Queue::ReportQueue::QUEUE_NAME).and_return(nil)
      SirTracksAlot::Queue::ReportQueue.pop      
    end
    
    it "should create report cache" do
      SirTracksAlot::Queue::ReportCache.should_receive(:find_or_create).with(:owner => 'owner', :report => 'target_report').and_return(@cache)
      SirTracksAlot::Queue::ReportQueue.pop      
    end
    
    it "should constantize report by name" do
      SirTracksAlot::Queue::QueueHelper.should_receive(:constantize).with("SirTracksAlot::Reports::TargetReport").and_return(SirTracksAlot::Reports::TargetReport)
      SirTracksAlot::Queue::ReportQueue.pop
    end        
    
    it "should build report HTML" do      
      SirTracksAlot::Queue::ReportCache.should_receive(:find_or_create).with(:owner => 'owner', :report => 'target_report').and_return(@cache)
      @cache.should_receive(:update) do |options|
        options[:html].should have_tag('td.target', /\/categories\/item1/)
      end
      SirTracksAlot::Queue::ReportQueue.pop
    end        
    
  end
  
  context 'when contantizing' do
    it "should support mixed" do
      # not sure why constantize has trouble with the be_instance_of matcher
      SirTracksAlot::Queue::QueueHelper.constantize('SirTracksAlot::Reports::ActorReport').to_s.should == 'SirTracksAlot::Reports::ActorReport'
    end
  end
end