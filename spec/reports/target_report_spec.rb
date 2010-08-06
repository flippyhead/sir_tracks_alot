require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Reports::TargetReport do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @activities.each{|a| SirTracksAlot.record(a)}
    SirTracksAlot::Count.count(:owner => 'owner')
  end  
  
  context 'building HTML' do
    before do             
      rows = SirTracksAlot::Count.rows(:owner => 'owner')
      @html = SirTracksAlot::Reports::TargetReport.render_html(:rows => rows, :report_class => 'customClass')
    end
    
    it_should_behave_like 'all reports'
    
    it "should include target row" do    
      @html.should have_tag('td.target', /\/categories\/item/)
    end

    it "should have custom class" do    
      @html.should have_tag('div.customClass')
    end

    it "should include count row" do      
      @html.should have_tag('td.count', /1/)
    end

    it "should ignore other owners" do
      @html.should_not have_tag('td.target', '/other_categories/item')
    end
  end
end