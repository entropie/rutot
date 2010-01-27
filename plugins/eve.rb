#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'reve'

include :eve

respond_on(:PRIVMSG, :tq, prefix_or_nick(:tq)) do |h|
  ss = API.server_status
  h.respond("Serverstatus: #{(ss.open and "up" or "down")}#{ss.open and " with #{ss.players} Players"}")
end


respond_on(:PRIVMSG, :kills, prefix_or_nick(:kills), :args => [:String]) do |h|
  arg = h.args.to_s.strip
  arg = "D-GTMI" if arg.empty?
  kills = get_mapkills_from_solarSystem(arg)
  begin
    ret = "%s Kills within the last hour: Ships: %i  Pods: %i  NPCs: %i" % [arg, kills.ship_kills, kills.pod_kills, kills.faction_kills]
    h.respond(ret)
  rescue
    h.respond("%s Kills: dunno" % arg)
  end
end

respond_on(:PRIVMSG, :starbases, prefix_or_nick(:starbases), :args => [:String]) do |h|
  arg = h.args.to_s.strip
  begin
    h.respond(starbase_details(arg.to_s.upcase))
  rescue
    h.respond("failed :/")
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
