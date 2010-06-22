module SirTracksAlot
  module Reports
    class Report < Ruport::Controller
      attr_accessor :all
      
      def setup
        self.data = []        
        options.report_class ||= ''
        options.report_title ||= 'Report'
      end
      
      module Helpers
        def self.handle(name, &block)
          @@handlers ||= {}
          name = [name] unless name.kind_of?(Array)

          name.each do |n|
            @@handlers[n] = block          
          end
        end
        
        def to_dom_class(words)
          (words||'').gsub(/[^a-z0-9]/, '_')
        end
        
        def render_data(name, value)
          @@handlers ||= {}          
          return value if !@@handlers.include?(name)
          @@handlers[name].call(value)
        end        
        
      end      
    end
  end
end