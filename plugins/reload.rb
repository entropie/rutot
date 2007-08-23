#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :reload, prefix_or_nick(:reload)) do |h|
  h.bot.plugins.reload
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
