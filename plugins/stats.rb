#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :channelstats, prefix_or_nick(:stats), :args => [:String]) do |h|

end

respond_on(:PRIVMSG, :seen, prefix_or_nick(:seen), :args => [:String], :arg_req => true) do |h|

  if a = h.bot.channels[h.channel].nicks
    p a
  end
  
  if sl = Database::SeenList.find_by_channel_and_nick(h.channel, nick=h.args.to_s)
    m = if sl.msg.empty? then '(no message)' else sl.msg end
    h.respond("Seen #{nick} at #{sl.time} - " + m)
  else
    'nope'
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
