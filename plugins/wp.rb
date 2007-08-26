#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'hpricot'
require 'open-uri'

def swpi(str)
  url = "http://en.wikipedia.org/wiki/#{str.capitalize}"
  h = Hpricot(open(url))
  "#{url}  " + h.at(:p).inner_text.gsub(/\n/, ' ')
end


respond_on(:PRIVMSG, :wp, prefix_or_nick(:wp), :args => [:Everything], :arg_req => true) do |h|
  h.respond(swpi(h.args.first.to_s))
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
