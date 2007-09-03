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

respond_on(:PRIVMSG, :more, prefix_or_nick(:more, :m)) do |h|
  begin
    h.respond(h.bot.spooler.more(h.channel).lines)
  rescue
    h.respond(ReplyBox.NO)
  end
end

respond_on(:PRIVMSG, :lorem, prefix_or_nick(:lorem)) do |h|
  h.respond("Lorem ipsum dolor sit amet, consectetur adipisicing elit",
            "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip  consequat.",
            "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
            "Sint occaecat cupidatat non , sunt in culpa qui officia deserun id est laborum.",
            "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            "Ut enim ad minim veniam, quis nostrud  laboris nisi ut aliquip ex ea commodo consequat.",
            "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
            "Excepteur sint occaecat cupidatat non  in culpa qui officia deserunt mollit anim id est laborum.",
            "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            "Ut enim ad minim veniam, quis nostrud  laboris nisi ut aliquip ex ea commodo consequat.",
            "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
            "Excepteur sint occaecat cupidatat non  qui officia deserunt mollit anim id est laborum.")

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

respond_on(:PRIVMSG, :uptime, prefix_or_nick(:uptime)) do |h|
  h.respond(`uptime`)
end

respond_on(:PRIVMSG, :nsregister, prefix_or_nick(:registerns)) do |h|
  h.bot.msg('NickServ', "register #{bot.config.freenode}")
  'k'
end


respond_on(:PRIVMSG, :quiet, prefix_or_nick(:quiet), :args => [:String]) do |h|
  begin
    if h.args.empty?
      h.bot.spooler.quiet!
    else
      h.bot.spooler.quiet!(h.args.join)
    end
  rescue
    ReplyBox.SRY
  end
end

respond_on(:PRIVMSG, :quietlist, prefix_or_nick(:quietlist)) do |h|
  h.bot.spooler.quiet_list.join(', ')
end

respond_on(:PRIVMSG, :talk, prefix_or_nick(:talk), :args => [:String]) do |h|
  begin
    if h.args.empty?
      h.bot.spooler.talk!
    else
      h.bot.spooler.talk!(h.args.join)
    end
    ReplyBox.k
  rescue
    p $!
    ReplyBox.SRY
  end
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
  arg = if not (str = h.args.first).empty?
          str
        else
          h.channel
        end
  h.respond(ReplyBox.k)
  h.bot.part(arg, `fortune drugs zippy -s chucknorris bofh-excuses wisdom fortunes`.to_irc_msg)
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
