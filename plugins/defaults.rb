#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :yo, /\w+\?\?+$/) do |h|
  h.respond(ReplyBox.YO)
end

respond_on(:PRIVMSG, :ping, prefix_or_nick(:ping)) do |h|
  :pong
end

respond_on(:PRIVMSG, :botsnack, prefix_or_nick(:botsnack)) do |h|
  [
   'My favorite snack!',
   'Yummy.',
   'Thanks a lot, sweety.',
   'Sage meinen Dank, Sai.',
   'Your place or my place?',
   'Gimme BEER, not cookies.'
  ].sort_by{ rand}.first
end

respond_on(:PRIVMSG, :LOC, prefix_or_nick(:LOC)) do |h|
  `/home/mit/bin/loc`.split("\n").join(' — ')
end

respond_on(:PRIVMSG, :kcode, prefix_or_nick(:kcode), :args => [:String]) do |h|
  h.respond $KCODE  
end


respond_on(:PRIVMSG, :source, prefix_or_nick(:source)) do |h|
  h.respond('HG repos available at http://ackro.ath.cx:8000')
end

respond_on(:PRIVMSG, :uptime, prefix_or_nick(:uptime)) do |h|
  h.respond(`uptime`)
end

respond_on(:PRIVMSG, :quiet, prefix_or_nick(:quiet)) do |h|
  h.bot.spooler.quiet!
end

respond_on(:PRIVMSG, :talk, prefix_or_nick(:talk)) do |h|
  h.bot.spooler.talk!
  h.respond(ReplyBox.k)
end

respond_on(:PRIVMSG, :quit, prefix_or_nick_r('quit$', :quit)) do |h|
  h.bot.quit `fortune drugs zippy -s chucknorris bofh-excuses wisdom fortunes`.to_irc_msg
end

respond_on(:PRIVMSG, :np, prefix_or_nick(:np)) do |h|
  h.respond(`/home/mit/bin/np`)
end

respond_on(:PRIVMSG, :help, prefix_or_nick(:help), :args => [:String] ) do |h|
  h.respond("What if you were on a lonely island?  " +
            "You should take some special trouble to get it yourself!")
end

respond_on(:PRIVMSG, :join, prefix_or_nick(:join, :j), :args => [:String] ) do |h|
  h.bot.join(h.args.first)
  h.respond(ReplyBox.k)
end

respond_on(:PRIVMSG, :part, prefix_or_nick(:part, :p), :args => [:String] ) do |h|
  h.bot.part(h.args.first)
  h.respond(ReplyBox.k)
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
