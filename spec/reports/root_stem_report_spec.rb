require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Reports::RootStemReport do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @activities.each{|a| SirTracksAlot.record(a)}
  end  
  
  it "should render empty" do
    SirTracksAlot::Reports::FilterReport.render_html(:owner => 'owner')
  end  
  
  context 'building HTML with categories' do
    before do       
      @html = SirTracksAlot::Reports::RootStemReport.render_html(:owner => 'owner', :roots => ['categories'])
    end
    
    it "include index filter" do
      @html.should have_tag('td', /categories pages/)
    end

    it "include individual page filter" do
      @html.should have_tag('td', /categories index/)
    end

    it "include count row" do      
      @html.should have_tag('td.count', /2/)
    end    
  end
  
  context 'building HTML without categories' do
    before do       
      @html = SirTracksAlot::Reports::RootStemReport.render_html(:owner => 'owner', :roots => ['categories'])
    end
    
    it "include index filter" do
      @html.should have_tag('td', /categories pages/)
    end

    it "include individual page filter" do
      @html.should have_tag('td', /categories index/)
    end

    it "include count row" do      
      @html.should have_tag('td.count', /2/)
    end    
  end
end