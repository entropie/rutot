#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


respond_on(:PRIVMSG, prefix(:fortune)) do |h|
  h.respond(`fortune -s`)
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
