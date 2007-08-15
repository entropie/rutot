#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, prefix(:date), :args => [:Integer]) do |h|
  unless h.args.empty?
    mdays = h.args.first
    tn = Time.now + mdays*24*60*60
    h.respond(tn)
  else
    h.respond(Time.now)
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
