module SirTracksAlot
  module Reports
    class SirTracksAlotReport < Report
      attr_accessor :all
      
      def setup
        super        
        options.categories = options.categories  #|| all.collect{|a| a.category}.uniq
        options.actions = options.actions #|| all.collect{|a| a.action}.uniq
      end      
    end
  end
end