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

Spec::Runner.configure do |config|
  config.include(RspecHpricotMatchers)
end

class RedisSpecHelper
  TEST_OPTIONS = {:db => 15}
  
  def self.reset   
    Ohm.connect(TEST_OPTIONS)
    Ohm.flush
  end
end

module DataHelper
  def initialize(*attrs)
    super
    
    @activities = [
      {:owner => 'owner', :target => '/categories/item1', :actor => '/users/user1', :action => 'view', :user_agent => 'agent1'},
      {:owner => 'owner', :target => '/categories/item2', :actor => '/users/user2', :action => 'view', :user_agent => 'agent2'},
      {:owner => 'owner', :target => '/categories',      :actor => '/users/user2', :action => 'view', :user_agent => 'agent2'},      
      {:owner => 'owner', :target => '/other_categories/item', :actor => '/users/user1', :action => 'view', :user_agent => 'agent1'},
      {:owner => 'owner', :target => '/other_categories/item', :actor => '/users/user2', :action => 'view', :user_agent => 'agent2'},
      {:owner => 'owner', :target => '/other_categories', :actor => '/users/user1', :action => 'view', :user_agent => 'agent1'},
      {:owner => 'owner', :target => '/other_categories', :actor => '/users/user2', :action => 'view', :user_agent => 'agent2'}
    ]

    @report_attributes = {:owner => 'owner', :roots => ['categories'], :actions => ['view']}    
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
