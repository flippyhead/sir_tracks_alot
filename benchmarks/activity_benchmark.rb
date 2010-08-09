require 'benchmarks/benchmark_helper'

@owner = 'owner'

RedisSpecHelper.reset
DataBuilder.build(1000)

Benchmark.bm do |b|    
  b.report('filtering by owner') do 
    SirTracksAlot::Activity.filter(:owner => @owner)
  end  

  b.report('filtering by target with regex (all match)') do 
    SirTracksAlot::Activity.filter(:owner => @owner, :target => /.+/)
  end
  
  b.report('filtering by target with regex (no matches)') do 
    SirTracksAlot::Activity.filter(:owner => @owner, :target => /xxxxxxx/)
  end  
  
  b.report('filtering by owner, and iterating') do
    SirTracksAlot::Activity.filter(:owner => @owner).collect{|a| a.target}
  end
  
  b.report('filtering and retrieve last_event') do 
    SirTracksAlot::Activity.filter(:owner => @owner).map{|a| a.last_event}
  end

  b.report('filtering and retrieve all events') do 
    SirTracksAlot::Activity.filter(:owner => @owner).map{|a| a.events.map{|e| e}}
  end
end

RedisSpecHelper.reset
