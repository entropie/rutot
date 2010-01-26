#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include :rss

$all = Rss.load

def get_last(curr)
  newf = Rss.load(true)
  begin
    Rss.feeds.map{|r| r.name}.each do |feedname|
      if curr[feedname].first["published"] != newf[feedname].first["published"]
        $all = newf
        yield [feedname, newf[feedname].first]
      end
    end
  rescue
    p $!
  end
end

# Rss.feeds.map{|r| r.name}.each do |feedname|
#   $all[feedname].first["published"] = Time.now
# end

timed_response(10, :auto_fetch_news) do |h|
  ret = []
  get_last($all) do |feedname, feed|
    ret << "[%s]: '%s' %s (%s)" % [feedname, feed["title"], hlp_tinyurl(feed["url"]), feed["published"]]
  end
  h.respond(ret)
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
