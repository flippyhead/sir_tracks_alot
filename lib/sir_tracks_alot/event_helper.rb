module SirTracksAlot
  module EventHelper
    DATE_FORMATS = {:hourly => '%Y/%m/%d %H', :daily => '%Y/%m/%d'}
    
    def views(resolution = nil)
      return events.size if resolution.nil?

      groups = {}

      date_format = resolution.kind_of?(String) ? resolution : DATE_FORMATS[resolution]

      events.each do |event|
        time = Time.at(event.to_i).utc.strftime(date_format) # lop of some detail
        groups[time.to_s] ||= 0
        groups[time.to_s] += 1 
      end

      return groups
    end

    # Count one visit for all events every session_duration (in seconds)
    # e.g. 3 visits within 15 minutes counts as one, 1 visit 2 days later counts as another
    def visits(sd = 1800, resolution = nil)
      session_duration = sd || 1800      
      last_event = events.first

      count = events.size > 0 ? 1 : 0 # in case last_event == event (below)
      groups = {}

      events.each do |event|
        boundary = (event.to_i - last_event.to_i > session_duration) # have we crossed a session boundary?

        if resolution.nil? # i.e. don't group
          count += 1 if boundary
        else
          date_format = resolution.kind_of?(String) ? resolution : DATE_FORMATS[resolution]
          time = Time.at(event.to_i).utc.strftime(date_format) # lop of some detail

          groups[time.to_s] ||= count
          groups[time.to_s] += 1 if boundary
        end

        last_event = event # try the next bounary
      end

      resolution.nil? ? count : groups
    end
  end  
end