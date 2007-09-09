#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include :theyfightcrime

respond_on(:PRIVMSG, :tfcp, prefix_or_nick(:theyfightcrime, :tfc)) do |h|
  begin
    h.respond(TheyFightCrime.new.movieplot)
  rescue
    h.respond ReplyBox.SRY
  end
end

respond_on(:PRIVMSG, :tfct, prefix_or_nick(:movietitle)) do |h|
  begin
    h.respond(TheyFightCrime.new.movietitle)
  rescue
    h.respond ReplyBox.SRY
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
