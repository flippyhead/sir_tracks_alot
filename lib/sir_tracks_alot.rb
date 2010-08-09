$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"
require "bundler"
Bundler.setup
Bundler.require 

# require 'logging'
# require 'twitter'
# require 'ruport'
# require 'ohm'
# require 'redis'

module SirTracksAlot
  TRACKABLE_ROOT = "#{File.dirname(__FILE__)}/.."
  
  autoload :Persistable, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot persistable.rb])
  autoload :Activity, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot activity.rb])
  autoload :EventHelper, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot event_helper.rb])
  autoload :FilterHelper, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot filter_helper.rb])
  autoload :Count, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot count.rb])
  autoload :Clock, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot clock.rb])  
  
  class SirTracksAlotError < StandardError    
  end

  class RecordInvalidError < SirTracksAlotError    
  end
    
  # Creates new activity with attribues: 
  #   :owner    => string to roll up all activities by e.g. /site/1
  #   :actor    => string representing who done it e.g. /profiles/peter-brown
  #   :target   => string representing where they done it e.g. /messages/some-subject
  #   :action   => what they done e.g. view or create
  #   :event    => Time.utc.to_i of when the action activity, defaults to now 
  def self.record(attributes)
    # event defaults to now unless overwritten
    event = (attributes.delete(:event) || Clock.now)
    request = attributes.delete(:request)
    
    # try to convert to trackable paths if possible
    [:target, :actor, :owner].each {|key| attributes[key] = attributes[key].respond_to?(:to_trackable_id) ? 
      attributes[key].to_trackable_id : 
      attributes[key].to_s}
    
    # automatically extract the root, assign to "category"
    attributes[:category] = attributes[:target].split('/')[1]
    
    # assign the user_agent from the request unless overritten 
    attributes[:user_agent] ||= (request.nil? ? nil : request.try(:user_agent))
    
    return if exclude?(attributes)
    
    # find or create
    activity = Activity.find_or_create(attributes)
    
    raise RecordInvalidError.new("Activity not valid: #{activity.errors.inspect}") unless activity.valid?

    activity.update(:last_event => event, :counted => '0')
    activity.events << event
    activity
  end
  
  # add a hash of attribute/filter pairs to ignore when recording activities
  # e.g. {:user_agent => /google/}, {:target => '/hidden', :actor => 'spy'}
  def self.exclude(row)
    @@filters ||= []
    @@filters << row
  end
  
  def self.exclude?(attributes)
    @@filters ||= []
    
    return false if @@filters.empty? || attributes.nil?
    
    @@filters.each do |filter|
      filter.each do |key, matcher|
        matcher = /#{matcher}/ if matcher.kind_of?(String)
        return true if attributes[key] =~ matcher
      end
    end
    
    false
  end
  
  def self.clear!
    @@filters = []
  end
  
  def log
    return @log if @log
    
    @log = Logging::Logger[self]
    @log.level = :debug
    @log
  end  
  
  module_function :log
  
  module Helper    
    def to_trackable_id
      '/'+[self.class.name.underscore.pluralize, self.to_param].join('/')
    end
    
    def find_by_trackable_id(trackable_id)
      parts = trackable_id.split('/')
      return unless parts.size == 3
      return part[1].constantize.find(parts[2])
    end    
  end
  
  module Queue
    autoload :ReportQueue, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot queue report_queue.rb])
    autoload :ReportCache, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot queue report_cache.rb])
    autoload :ReportConfig, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot queue report_config.rb])
    autoload :QueueHelper, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot queue queue_helper.rb])
  end
  
  module Reports
    autoload :Report, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot reports report.rb])
    autoload :SimpleReport, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot reports simple_report.rb])
    autoload :BasicReport, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot reports basic_report.rb])
    autoload :SirTracksAlotReport, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot reports trackable_report.rb])
    autoload :TargetReport, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot reports target_report.rb])
    autoload :ActorReport, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot reports actor_report.rb])    
    autoload :ActorActivityReport, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot reports actor_activity_report.rb])    
    autoload :ActivityReport, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot reports activity_report.rb])    
    autoload :FilterReport, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot reports filter_report.rb])    
    autoload :RootStemReport, File.join(File.dirname(__FILE__), *%w[sir_tracks_alot reports root_stem_report.rb])        
  end
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, SirTracksAlot::Helper)
end

