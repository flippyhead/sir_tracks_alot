require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Reports::ActorReport do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @activities.each{|a| SirTracksAlot.record(a)}
  end  
  
  context 'building HTML' do
    before do 
      @counts = SirTracksAlot::Count.count(:owner => 'owner')
      @html = SirTracksAlot::Reports::ActorReport.render_html(:counts => @counts)
    end
    
    # it "include target row" do
    #   @html.should have_tag('td.actor',/\/users\/user1/)
    # end
    # 
    # it "include count row" do      
    #   @html.should have_tag('td.count', /1/)
    # end
    # 
    # it "include page views" do      
    #   @html.should have_tag('td.page_views', /2/)
    # end
    #   
    # it "should ignore other owners" do
    #   @html.should_not have_tag('td.actor', '/users/user')
    # end
  end
end