#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include :rss

Feeds = Hash[*Rss.feeds.map{|f| [f.name, Rss.load[f.name].first]}.flatten]

timed_response(intv=10, :auto_fetch_news) do |h|
  ret = []
  begin
    Feeds.each do |feedname, feed|
      top = Rss.load[feedname].first
      if top["dc_date"] != feed["dc_date"] or top["title"] != feed["title"]
        ret << feed_to_s(feedname, top)
        Feeds[feedname] = top
      end
    end
    h.respond(ret)
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
