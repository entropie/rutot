#
# $Id: 88 Michael Trommer <mictro@gmail.com>: message are recorded during ,quiet and saved in ,more$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

timed_response(60*60, :auto_fortunes) do |h|
  h.respond(hlp_fortune)
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
