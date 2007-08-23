#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :plugins, prefix_or_nick(:plugins)) do |h|
  pls = bot.config.channels[h.channel]
  m =
    if pls.respond_to? :plugins
      pls.plugins
    else
      bot.config.base_mods
    end
    h.respond m.join(', ')
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
