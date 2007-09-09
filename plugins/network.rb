#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :host, prefix_or_nick(:host), :args => [:String], :args_req => true) do |h|
  begin
    h.respond(`host #{h.args.to_s}`)
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