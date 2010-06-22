require 'rubygems'
require 'ohm'
require 'lib/trackable'

Ohm.connect(:host => 'localhost.com', :timeout => 10)

@owner = '/events/md10'

activities_count = Trackable::Activity.filter(:owner => @owner).size
events_count = 0; Trackable::Activity.filter(:owner => @owner).each{|a| events_count += a.events.size}

puts "**** Running benchmarks against dataset with #{activities_count} activities and #{events_count} events:"

Benchmark.bmbm do |b|  
  
  b.report('grabbing all activities, and iterating') do
    Trackable::Activity.filter(:owner => @owner).collect{|a| a.target}
  end
  
  b.report('filter only') do 
    Trackable::Activity.filter(:owner => @owner)
  end
  
  b.report('filter and retrieve last_event') do 
    Trackable::Activity.filter(:owner => @owner).map{|a| a.last_event}
  end

  b.report('filter and retrieve all events') do 
    Trackable::Activity.filter(:owner => @owner).map{|a| a.events.map{|e| e}}
  end

  b.report('count_by daily') do 
    counts = Trackable::Activity.count_by(:daily, :owner => @owner)    
  end  
end
