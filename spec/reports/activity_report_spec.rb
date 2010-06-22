require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Reports::ActivityReport do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @report_options = {:owner => 'owner', :actor => 'actor'}
  end  
  
  it "should render empty" do
    SirTracksAlot::Reports::ActivityReport.render_html(@report_options)
  end  
  
  context 'building HTML' do
    before do 
      @activities.each{|a| SirTracksAlot.record(a)}
      @html = SirTracksAlot::Reports::ActivityReport.render_html(@report_attributes)
    end
    
    it "include target row" do
      @html.should have_tag('td.target', /\/categories\/item/)
    end

    it "include count row" do      
      @html.should have_tag('td.event', :count => @activities.size)
    end
  end
  
end