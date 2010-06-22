require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SirTracksAlot::Reports::ActorActivityReport do 
  include DataHelper
  
  before do 
    RedisSpecHelper.reset
    @activities.each{|a| SirTracksAlot.record(a)}    
  end  
  
  context 'building HTML' do
    before do       
      @html = SirTracksAlot::Reports::ActorActivityReport.render_html(:owner => @activities[0][:owner], :actor => @activities[0][:actor])
    end
    
    it "should so and so" do
      @html.should have_tag('td', /\/categories\/item1/)
    end
  end
  
end