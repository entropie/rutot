#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, prefix_or_nick(:date), :args => [:Integer]) do |h|
  format = "%x - %A, %3j"
  unless h.args.empty?
    mdays = h.args.first
    tn = Time.now + mdays*24*60*60
    h.respond(tn.strftime(format))
  else
    h.respond(Time.now.strftime(format))
  end
end.name='date'

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
