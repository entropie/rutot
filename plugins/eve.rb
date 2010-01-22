#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'reve'

# if File.exist?(file="/Users/mit/.eve_api.rb")
#   require file
# else
#   require File.expand_path("~/.eve_api.rb")
# end

require "/Users/mit/eve.rb"

#api = Reve::API.new(UID, APIK)

respond_on(:PRIVMSG, :tq, prefix_or_nick(:tq)) do |h|
  ss = api.server_status
  h.respond("Serverstatus: #{(ss.open and "up" or "down")}#{ss.open and " with #{ss.players} Players"}")
end


respond_on(:PRIVMSG, :kills, prefix_or_nick(:kills), :args => [:String]) do |h|
  arg = h.args.to_s.strip
  arg = "D-GTMI" if arg.empty?
  kills = get_mapkills_from_solarSystem(arg)
  begin
    ret = "%s Kills: Ships: %i  Pods: %i  NPCs: %i" % [arg, kills.ship_kills, kills.pod_kills, kills.faction_kills]
    h.respond(ret)
  rescue
    h.respond("%s Kills: dunno" % arg)
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
