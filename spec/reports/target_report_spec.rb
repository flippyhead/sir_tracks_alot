require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Reports::TargetReport do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @activities.each{|a| SirTracksAlot.record(a)}
    @mock_finder = mock('Finder', :find => [], :collect => [])
    @mock_filter = mock('Filter', :each => [])
  end  
  
  it "should raise error on missing options" do
    lambda{SirTracksAlot::Reports::TargetReport.render_html({})}.should raise_error(Ruport::Controller::RequiredOptionNotSet)
  end
  
  it "should find activities when building data" do
    SirTracksAlot::Activity.should_receive(:filter).with(
      :action => @activities[0][:action], :owner => @activities[0][:owner], :target => nil, :category=>"categories").exactly(1).times.and_return(@mock_filter)
    SirTracksAlot::Reports::TargetReport.render_html(@report_attributes)
  end
  
  context 'building HTML without filters' do
    before do 
      SirTracksAlot.record(:owner => 'other_owner', :category => 'other_category', :target => '/other_categories/item', :actor => '/users/user', :action => 'view')
      @html = SirTracksAlot::Reports::TargetReport.render_html(@report_attributes)
    end
    
    it_should_behave_like 'all reports'
    
    it "include target row" do
      @html.should have_tag('td.target', /\/categories\/item/)
    end

    it "include count row" do      
      @html.should have_tag('td.count', /1/)
    end
  
    it "should ignore other owners" do
      @html.should_not have_tag('td.target', '/other_categories/item')
    end
  end
  
  context 'building HTML with filters' do
    before do 
      @html = SirTracksAlot::Reports::TargetReport.render_html(
        @report_attributes.merge(
          :filters => {:except => [{:target => /^\/categories$/}]}
        )
      )
    end
    
    it "should include non excepted target row" do
      @html.should have_tag('td.target', /\/categories\/item/)
    end  
    
    it "should not include excepted target row" do
      @html.should_not have_tag('td.target', /^\/categories$/)
    end  
    
  end
end