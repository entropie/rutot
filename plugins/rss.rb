#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include :rss

respond_on(:PRIVMSG, :news, prefix_or_nick(:news), :args => [:Everything]) do |h|
  arg = h.args.join.strip

  f = Rss.load
  ret = []

  if Rss.feeds.map{|r| r.name}.include?(arg)
    feedname, feed = arg, f[arg].first
    ret << feed_to_s(feedname, feed)
  else
    Rss.feeds.map{|r| r.name}.each do |feedname|
      feed = f[feedname].first
      ret << feed_to_s(feedname, feed)
    end
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
