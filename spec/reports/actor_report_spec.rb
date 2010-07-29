require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Reports::ActorReport do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    
    counts = {"/users/user1" => [2, 1], "/users/user2" => [2, 1], "/users/user3" => [0, 0]}    
    @report_attributes = {:owner => 'owner', :roots => ['categories'], :actions => ['view'], :counts => counts}    
  end  
  
  it "should find activities when building data" do
    @html = SirTracksAlot::Reports::ActorReport.render_html(@report_attributes)    
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

    it "include page views" do      
      @html.should have_tag('td.page_views', /2/)
    end
  
    it "should ignore other owners" do
      @html.should_not have_tag('td.actor', '/users/user')
    end
  end
end