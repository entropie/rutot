#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, prefix_or_nick(:join), :args => [:String] ) do |h|
  h.bot.join(h.args.first)
  h.respond(ReplyBox.k)
end

respond_on(:PRIVMSG, prefix_or_nick(:part), :args => [:String] ) do |h|
  h.bot.part(h.args.first)
  h.respond(ReplyBox.k)
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
