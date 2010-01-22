#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'reve'

if File.exist?(file="/Users/mit/.eve_api.rb")
  require file
else
  require File.expand_path("~/.eve_api.rb")
end

api = Reve::API.new(UID, APIK)

respond_on(:PRIVMSG, :tq, prefix_or_nick(:tq)) do |h|
  ss = api.server_status
  h.respond("Serverstatus: #{(ss.open and "up" or "down")}#{ss.open and " with #{ss.players} Players"}")
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
