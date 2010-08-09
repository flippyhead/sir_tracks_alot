require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Reports::SimpleReport do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @activities.each{|a| SirTracksAlot.record(a)}
    SirTracksAlot::Count.count(:owner => 'owner')
  end  
  
  context 'building HTML' do    
    context 'for table reports' do
      before do             
        @html = SirTracksAlot::Reports::SimpleReport.render_html(:filters => [{:owner => 'owner'}], 
          :report_class => 'customClass')
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
    
    context 'for table reports' do
      before do             
        @html = SirTracksAlot::Reports::SimpleReport.render_html(:filters => [{:owner => 'owner'}], 
          :group => 'target',
          :column_names => ['target', 'column 1', 'column 2'],
          :report_class => 'customClass')
      end

      it "should include target group" do
        @html.should have_tag('h2', /\/categories\/item/)
      end

      it "should include custom column names" do
        @html.should have_tag('th.column_1')
      end      
      
    end
  end
end