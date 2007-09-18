#
# $Id: 124 Michael Trommer <mictro@gmail.com>: mostly plugin base$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include :insult

respond_on(:PRIVMSG, :insult, prefix_or_nick(:insult, :i), :args => [:Everything], :args_req => true) do |h|
  begin 
    h.respond(("%s is %s!" % [h.args.join(' '), Insult.new.generate_insult]).capitalize)
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
