begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

require "rubygems"
require "bundler"
Bundler.setup(:development)
Bundler.require(:development)

require 'spec/reports/shared_report_specs'
require 'sir_tracks_alot'
require 'spec/redis_spec_helper'

Spec::Runner.configure do |config|
  config.include(RspecHpricotMatchers)
end

module DataHelper
  def initialize(*attrs)
    super
    
    @set_activities = [
      {:owner => 'owner', :target => '/categories/item1', :actor => '/users/user1', 
        :action => 'view', :user_agent => 'agent1', :event => 1279735846}, # 1.day.ago
        
      {:owner => 'owner', :target => '/categories/item1', :actor => '/users/user1', 
        :action => 'view', :user_agent => 'agent1', :event => 1279735846}, # 1.day.ago
        
      {:owner => 'owner', :target => '/categories/item1', :actor => '/users/user1', 
        :action => 'view', :user_agent => 'agent1', :event => 1279718578}, # 1.2.days.ago

      {:owner => 'owner', :target => '/categories/item1', :actor => '/users/user1', 
        :action => 'view', :user_agent => 'agent1', :event => 1279709941}, # 1.3.days.ago

      {:owner => 'owner', :target => '/categories/item2', :actor => '/users/user2', 
        :action => 'view', :user_agent => 'agent2', :event => 1279735846}, # 1.day.ago
        
      {:owner => 'owner', :target => '/categories', :actor => '/users/user2', 
        :action => 'view', :user_agent => 'agent2', :event => 1279735846}, # 1.day.ago
        
      {:owner => 'owner', :target => '/other_categories/item', :actor => '/users/user1', 
        :action => 'view', :user_agent => 'agent1', :event => 1279735846}, # 1.day.ago
        
      {:owner => 'owner', :target => '/other_categories/item', :actor => '/users/user2', 
        :action => 'view', :user_agent => 'agent2', :event => 1279735846}, # 1.day.ago
        
      {:owner => 'owner', :target => '/other_categories', :actor => '/users/user1', 
        :action => 'view', :user_agent => 'agent1', :event => 1279735846}, # 1.day.ago
        
      {:owner => 'owner', :target => '/other_categories', :actor => '/users/user2', 
        :action => 'view', :user_agent => 'agent2', :event => 1279735846} # 1.day.ago
    ]
    
    @activities = [
      {:owner => 'owner', :target => '/categories/item1', :actor => '/users/user1', :action => 'view', :user_agent => 'agent1'},
      {:owner => 'owner', :target => '/categories/item2', :actor => '/users/user2', :action => 'view', :user_agent => 'agent2'},
      {:owner => 'owner', :target => '/categories',      :actor => '/users/user2', :action => 'view', :user_agent => 'agent2'},      
      {:owner => 'owner', :target => '/other_categories/item', :actor => '/users/user1', :action => 'view', :user_agent => 'agent1'},
      {:owner => 'owner', :target => '/other_categories/item', :actor => '/users/user2', :action => 'view', :user_agent => 'agent2'},
      {:owner => 'owner', :target => '/other_categories', :actor => '/users/user1', :action => 'view', :user_agent => 'agent1'},
      {:owner => 'owner', :target => '/other_categories', :actor => '/users/user2', :action => 'view', :user_agent => 'agent2'}
    ]
    
    @counts = {"/categories" => [1, 1], "/categories/item1" => [1, 1], "/categories/item2" => [1, 1]}
    
    @report_attributes = {:owner => 'owner', :roots => ['categories'], :actions => ['view'], :counts => @counts}
  end
end

class SirTracksAlot::Reports::CustomTargetReport < SirTracksAlot::Reports::TargetReport
  def setup
    super
  end
  
  module Helpers
    def render_target(t)
      'customziherecheeseburger'
    end
  end
  
  class HTML < Ruport::Formatter::HTML
    renders :html, :for => SirTracksAlot::Reports::CustomTargetReport

    build :drill_down do
      output << erb((options.template || TRACKABLE_ROOT+"/views/reports/target.html.erb"), :binding => binding)
    end    
  end                    
end        
