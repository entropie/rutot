#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, prefix_or_nick(:version)) do |h|
  h.respond("Rutlov, the friendly Ruby Bot: Version: %s" % Rutot.version,
            "+ http://pb.ackro.org/static/p/ackro.html")
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
