#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :channelstats, prefix_or_nick(:stats), :args => [:String]) do |h|

end

respond_on(:PRIVMSG, :seen, prefix_or_nick(:seen), :args => [:String], :arg_req => true) do |h|
  nick=h.args.to_s
  if h.bot.channels[h.channel].nicks.keys.include?(nick)
    h.respond("#{nick.capitalize} is online right now.")
  elsif sl = Database::SeenList.find_by_channel_and_nick(h.channel, nick)
    m = if sl.msg.empty? then '(no message)' else sl.msg end
    h.respond("Seen #{nick} at #{sl.time} - " + m)
  else
    'Nope.'
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
