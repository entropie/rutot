#
# $Id: 123 Michael Trommer <mictro@gmail.com>: plugins/weather.rb: grep all args, and escape query-string$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'cgi'
require 'enumerator'
require 'open-uri'
require 'cgi'
require 'hpricot'
require 'pp'



WFields = ['Temperature','Wind','Pressure','Humidity','Conditions','Sunrise','Moon Rise','Visibility']
WMessage = "Temperature is %i°C (Chill is %i°C) with a Pressure of %ihPa and a Humidity of %s, %s\nSunrise at %s and Moon Rise at %s. Visibility %s."

def weather(str)
  station = "http://mobile.wunderground.com/cgi-bin/findweather/getForecast?query=#{CGI.escape(str)}"
  doc = Hpricot(open(station))

  results = doc.at("center")
  header, location = (results/"td[@colspan='2']/b").map{ |a| a.inner_html}


  ret = { }
  (results/"td")[1..-1].each_slice(2) do |d, v|
    ret[d.inner_html] = []
    r = 
      if (r =(v/"span")).empty?
        ret[d.inner_html] << v.inner_html.gsub(/\s+/, ' ').strip.gsub(/<\/?b>/, '')
      else
        ret[d.inner_html] << r.map{ |r| (r/"b").inner_html.strip }
      end
    ret[d.inner_html] = ret[d.inner_html].flatten
  end
  ret = ret.select{ |n,v| WFields.include?(n)}.sort_by{ |n,v| WFields.index(n) || 100}.
    map{ |n,v| v.kind_of?(Array) ? v.last : v}
  "#{location} — #{header}\n" + WMessage % [*ret]
end

respond_on(:PRIVMSG, :weather, prefix_or_nick(:wheater, :w), :args => [:Everything]) do |h|
  begin
    unless h.args.join.empty?
      h.respond(weather(h.args.flatten.join(' ')))
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
