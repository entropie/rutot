#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


#  weather.rb (c) October 2006 by manveru <manveru@weez-int.com>
#
#  Description:  show the weather for +str* (example 'tokyo','berlin germany'

require 'open-uri'
require 'cgi'
require 'hpricot'

def weather(str)
  station = "http://mobile.wunderground.com/cgi-bin/findweather/getForecast?query=#{str}"
  doc = Hpricot(open(station))

  results = doc.search('/html/body//b').map{|r| r.inner_html}
  time, location, temperature, windchill, humidity, dewpoint, wind_direction, 
  wind_speed, pressure, conditions, visibility, cloud_height, 
  cloud_conditions = *results

  time = Time.parse(time).strftime("%d.%m.%Y %H:%M")
  temperature << "°C"
  dewpoint    << "°C"

  return("Weather in #{location} at #{time}: #{conditions}, #{temperature} - (Humidity is at #{humidity})")
end

respond_on(:PRIVMSG, :weather, prefix_or_nick(:wheater, :w), :args => [:String]) do |h|
  begin
    unless h.args.join.empty?
      h.respond(weather(h.args.join))
    else
      h.respond('Say to me where you lurk around, dood.')
    end
  rescue
    p $!
  end
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
