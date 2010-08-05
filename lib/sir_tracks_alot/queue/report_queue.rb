module SirTracksAlot
  module Queue
    class ReportQueue < Persistable
      QUEUE_NAME = 'trackable_queue'

      attribute :created_at
      attribute :name
      index :name
      list :queue # of ReportConfigs

      def self.push(owner, report, options)
        config = ReportConfig.find_or_create(:owner => owner.to_s, :report => report.to_s)
        config.options = options.merge(:owner => owner.to_s) # reports require owner, should be sync'd with config owner        
        queue = self.find_or_create(:name => QUEUE_NAME)
        queue.queue << config.id
      end

      def self.pop
        queue = self.find(:name => QUEUE_NAME)
        
        if queue.nil? || queue.first.nil?
          SirTracksAlot.log.info("Reports queue has not been created yet.")
          return false
        end
        
        queue = queue.first
        
        config = ReportConfig[queue.queue.pop] # raw gets us just the id's, pop to remove the las one, it's a queue!
      
        process(config)
      end
    
      def self.process(config)
        return false if config.nil?

        SirTracksAlot.log.info("building report: #{config.inspect}")

        begin
          report = QueueHelper.constantize(QueueHelper.camelize("SirTracksAlot::Reports::#{config.report.capitalize}"))
          counts = Count.filter(config.options)
          html = report.render_html(:counts => counts)
          cache = ReportCache.find_or_create(:owner => config.owner, :report => config.report)
          cache.update(:html => html)
        rescue Exception => e
          SirTracksAlot.log.fatal("Error building report #{config.report} for #{config.owner}: #{e}")
        end

        true
      end      
    end
  end
end

# TODO: ability to easily run single reports
# e = Event.find_by_domain 'community.mitcio.com'
# SirTracksAlot::Queue::ReportConfig.find(:owner => e.to_trackable_id)
# c = SirTracksAlot::Queue::ReportConfig.find(:owner => e.to_trackable_id).all[-1]
# SirTracksAlot::Queue::ReportQueue.process(c)