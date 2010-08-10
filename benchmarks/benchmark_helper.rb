require "rubygems"
require "bundler"
Bundler.setup(:development)
Bundler.require(:development)
require 'lib/sir_tracks_alot'
require 'benchmark'
require 'spec/redis_spec_helper'

Ohm.connect(:host => '127.0.0.1', :timeout => 2, :db => 15)

class DataBuilder
  START_DATE = 1272559940
  ONE_HOUR = 3600
  
  def self.build(count = 1000, owner = 'owner', ref_count = 100)
    puts "** Building activities..."
    
    count.times do |i|
      event = START_DATE + (ONE_HOUR * i)
      target = "/targets/#{rand ref_count}"
      actor = "/actors/#{rand ref_count}"
      user_agent = "user_agents-#{rand ref_count}"
      view = 'view'
      
      SirTracksAlot.record(:owner => owner, :event => event, :target => target, :actor => actor, :user_agent => user_agent, :action => view)
    end
    
    puts "** Done building #{count} activities."
  end
end