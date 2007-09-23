#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :date, prefix_or_nick(:date, :time), :args => [:Integer]) do |h|
  format = "%x - %A, M:%m D:%3j Y:%Y"
  ts =
    unless h.args.empty?
      mdays = h.args.first
      tn = Time.now + mdays*24*60*60
      [tn, tn.strftime(format)]
    else
      [tn = Time.now, tn.strftime(format)]
    end
  h.respond(ts.last + " — #{tn.to_i}")
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
