require 'rubygems'
require 'ohm'
require 'lib/trackable'

Ohm.connect(:host => 'localhost.com', :timeout => 10)

@owner = '/events/md10'
@categories = Trackable::Activity.filter(:owner => @owner).collect{|a| a.category}.uniq
@actions = Trackable::Activity.filter(:owner => @owner).collect{|a| a.action}.uniq

activities_count = Trackable::Activity.filter(:owner => @owner).size
events_count = 0; Trackable::Activity.filter(:owner => @owner).each{|a| events_count += a.events.size}

puts "** Running benchmarks against dataset with #{activities_count} activities, #{events_count} events, and #{@categories.size} categories:"

Benchmark.bmbm do |b|  
  b.report('targer report') do     
    report = Trackable::Reports::TargetReport.render_html(:owner => @owner, :roots => @categories, :actions => @actions)
    # puts report
  end  
end
