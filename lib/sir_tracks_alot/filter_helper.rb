module SirTracksAlot
  module FilterHelper        
    # Find activities that match attributes 
    # Strings are passed to Ohm
    # Regular Expression filters match against retrieved attribute values
    # 
    # filter(:actor => 'user1', :target => /\/targets\/\d+/, :action => ['view', 'create'], :category => ['/root', '/other_root'])
    def filter(options_for_find, &block)      
      items = []
      all = []
      
      strings, matchers, arrays = extract_filter_options(options_for_find)
      
      unless arrays.empty?
        (arrays.values.inject{|a, b| a.product b}).each do |combo|
          terms = {}; combo.each{|c| terms[find_key_from_value(arrays, c)] = c}
          all += find(terms.merge(strings)).to_a
        end
      else
        all = find(strings)
      end

      all.each do |item|
        pass = true
        
        matchers.each do |key, matcher|
          pass = false if !matcher.match(item.send(key))
        end

        next unless pass
        
        yield item if block_given?
        
        items << item
      end
      
      items      
    end
    
    def extract_filter_options(options)
      strings = {}
      matchers = {}
      arrays = {}
      
      options.each do |key, candidate|
        matchers[key] = candidate      if candidate.kind_of?(Regexp)  && !candidate.blank?
        strings[key]  = candidate.to_s if (candidate.kind_of?(String)) && !candidate.blank?
        arrays[key]   = candidate      if candidate.kind_of?(Array)   && !candidate.blank?
      end
      
      [strings, matchers, arrays]
    end
  end
end