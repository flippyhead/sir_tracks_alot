module SirTracksAlot
  module Reports
    class RootStemReport < FilterReport
      stage :base
      
      required_option :owner      
      
      # Build up reports by filtering things as follows:
      # actions = []
      # roots = {}
      def setup        
        options.actions ||= Activity::ACTIONS
        options.filters ||= {}
        
        options.actions.each do |action|
          options.roots.each do |root|
            cat, target = root.kind_of?(Array) ? root : [root, root]
            
            begin
              options.filters["#{cat||target} index"] = {:category => cat, :target => /^\/#{target}$/, :action => action}
              options.filters["#{cat||target} pages"] = {:category => cat, :target => /^\/#{target}\/.+$/, :action => action}
            rescue RegexpError
              # swallow
            end
          end
        end
        
        super
      end
            
      module Helpers
        include Report::Helpers
      end

      class HTML < Ruport::Formatter::HTML    
        renders :html, :for => RootStemReport

        build :base do
          output << erb(options.template || TRACKABLE_ROOT+"/views/reports/table.html.erb", :binding => binding)
        end    
      end      
    end
  end
end