require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Reports::BasicReport do 
  include DataHelper
  
  before do 
    @report_options = {'data' => [
      ['Group 1', 'Title', 1],
      ['Group 3', 'Title', 99],
      ['Group 2', 'Title', 2]
    ]}
    RedisSpecHelper.reset
  end  
  
  it "should render empty" do
    SirTracksAlot::Reports::BasicReport.render_html(@report_options)
  end  
  
  context 'building HTML' do
    before do 
      @html = SirTracksAlot::Reports::BasicReport.render_html(@report_options)
    end
    
    it "include target row" do
      @html.should have_tag('td.title', /Title/)
    end

    it "include count row" do      
      @html.should have_tag('td.count', /1/)
    end
  
    it "should include group title" do
      @html.should have_tag('h2', /Group 1/)
    end
    
    it "should include both group titles" do
      @html.should have_tag('h2', :count => 3)
    end

    it "should include both group targets" do
      @html.should have_tag('table td.title', :count => 3)
    end        
  end
  
  context 'using custom handlers' do
    before do 
      SirTracksAlot::Reports::Report::Helpers.handle('title') do |value|
        "--#{value}--"
      end
      
      @html = SirTracksAlot::Reports::BasicReport.render_html(@report_options)
    end    

    it "should include custom title values" do
      @html.should have_tag('table td.title', /\-\-Title\-\-/)
    end    
  end
end