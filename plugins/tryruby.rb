#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael Fellinger <m.fellinger@gmail.com>
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'open-uri'
include :tryruby
try = TryRuby.new

respond_on(:PRIVMSG, :irb, prefix_or_nick(:irb, :eval), :args => [:Everything], :arg_req => true) do |h|
  #try.reload_session if try.eval("1") == ""
  h.respond try.eval(h.args.join(' '))
end

respond_on(:PRIVMSG, :irbreset, prefix_or_nick(:irb_reset)) do |h|
  try.reload_session
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
