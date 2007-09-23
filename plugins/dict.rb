#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :dict, prefix_or_nick(:dict), :args => [:String], :arg_req => true) do |h|
  begin
    h.respond `wn #{h.args.first} -over`.split(/\n\n/).last.split("\n").compact.reject{|a| a.strip.empty?}
  rescue
    h.respond ReplyBox.NO
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
