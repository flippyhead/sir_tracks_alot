require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Reports::TargetReport do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @activities.each{|a| SirTracksAlot.record(a)}
  end  
  
  context 'building HTML' do
    before do             
      @counts = SirTracksAlot::Count.count(OpenStruct.new(:owner => 'owner', :roots => ['categories']))
      @html = SirTracksAlot::Reports::TargetReport.render_html(:counts => @counts)
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
end