require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Reports::ActorReport do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @activities.each{|a| SirTracksAlot.record(a)}
    @mock_finder = mock('Finder', :find => [], :collect => [], :each => [])
  end  
  
  it "should raise error on mission options" do
    lambda{SirTracksAlot::Reports::ActorReport.render_html({})}.should raise_error(Ruport::Controller::RequiredOptionNotSet)
  end
  
  it "should find activities when building data" do
    SirTracksAlot::Activity.should_receive(:find).exactly(1).times.and_return(@mock_finder)
    SirTracksAlot::Reports::ActorReport.render_html(@report_attributes)
  end
  
  context 'building HTML' do
    before do 
      SirTracksAlot.record(:owner => 'other_owner', :target => '/other_categories/item', :actor => '/users/user', :action => 'view')
      @html = SirTracksAlot::Reports::ActorReport.render_html(@report_attributes)
    end
    
    it "include target row" do
      @html.should have_tag('td.actor',/\/users\/user1/)
    end

    it "include count row" do      
      @html.should have_tag('td.count', /1/)
    end
  
    it "should ignore other owners" do
      @html.should_not have_tag('td.actor', '/users/user')
    end
  end
end