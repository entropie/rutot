#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include :hgwatch

hg = HGWatch.new

respond_on(:PRIVMSG, :hg, prefix_or_nick(:hg)) do |h|
  if hg.empty?
    h.respond('nothing atm')
  else
    h.respond(hg.last)
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
