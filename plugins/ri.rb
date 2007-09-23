#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include :ri

respond_on(:PRIVMSG, :ri, prefix_or_nick(:ri), :args => [:String], :arg_req => true) do |h|
  begin 
    h.respond(Ri[h.args.first])
  rescue
    h.respond(ReplyBox.SRY)
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
