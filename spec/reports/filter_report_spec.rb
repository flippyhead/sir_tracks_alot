require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Reports::FilterReport do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @report_options = {:owner => 'owner'}
    @activities.each{|a| SirTracksAlot.record(a)}
    SirTracksAlot::Count.count(OpenStruct.new(:owner => 'owner', :roots => ['categories']))
  end  
  
  context 'filtering things with only' do
    before do 
      @report_options = {
        :owner => 'owner', 
        :filters => {
          'index' =>  {:target => /^\/categories$/}, 
          'pages' =>  {:target => /\/categories\/.+/}, 
          'blank' =>  {:target => /blanks/}
        }
      }
      
      @html = SirTracksAlot::Reports::FilterReport.render_html(@report_options)
    end
    
    it "should include index filter" do
      @html.should have_tag('td.title', /index/)
    end

    it "should include individual page filter" do
      @html.should have_tag('td.title', /pages/)
    end

    it "should include correct count row" do
      @html.should have_tag('td.count', /1/)
    end    
    
    it "should not include matches for blank" do
      @html.should_not have_tag('td.title', /blank/)
    end    
  end
  
end