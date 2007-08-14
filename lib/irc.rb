#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  class Connections < Array
    
    def <<(cntccls)
      con = Connection.new(cntccls)
      puts :CON, "connection handle `%s@%s´ saved" % [con.config.nick, con.config.servername]
      puts :CHN, "", con.config.channels.join(', ')
      push(con)
      con
    end

    def to_s
      inject([]) { |m, obj|
        m << "%-20s %s" % [obj.config.servername, obj.config.channels.join(', ')]
      }.join("\n")
    end

    def self.connect_all(daemon, bot)
      daemon.connections.each do |connection|
        puts :CON,
        "calling connect: #{connection.config.nick}@#{connection.server}"
        connection.connect!(bot)
      end
    end
    
  end
  
  class Connection

    attr_reader :config, :connected, :bot

    def initialize(config)
      @config, @connected = config, false
    end

    def connect!(bot)
      @bot = bot
      add_event_handler!
      @bot.connect
      p @bot.loop
    end
    
    def server; config.servername; end
    def port  ; config.port;       end

    def add_event_handler!

      @bot.conn.add_event(:RPL_NAMREPLY, :add_names_to_nicklist) do |msg, conn|
        nicks = msg.params.last
        channel = msg.params[-2]
        nicks.split.each do |nick|
          op = !!nick.gsub!(/@/,'')
          voice = !!nick.gsub!(/\+/,'')
          @bot.nicklist[channel.dc][nick.dc] = State.new(op, voice)
        end
        :success
      end
      @bot.conn.add_event(:JOIN, :add_name_to_nicklist) do |msg, conn|
        nick = msg.prefix[/[^:!]+/]
        channel = msg.params.first
        @bot.nicklist[channel.dc][nick.dc] = State.new(false, false)
        :success
      end
      @bot.conn.add_event(:PART, :remove_name_from_nicklist) do |msg, conn|
        nick = msg.prefix[/[^:!]+/]
        channel = msg.params.first
        @bot.nicklist[channel.dc].delete nick.dc
        :success
      end
      @bot.conn.add_event(:KICK, :remove_name_from_nicklist) do |msg, conn|
        nick    = msg.params[1]
        channel = msg.params[0]
        @bot.nicklist[channel.dc].delete nick.dc
        :success
      end
      @bot.conn.add_event(:NICK, :move_name_in_nicklist) do |msg, conn|
        nick = msg.prefix[/[^:!]+/]
        newnick = msg.params.last
        @bot.nicklist.each do |channel, sublist|
          entry = sublist.delete nick.dc
          if entry
            sublist[newnick.dc] = entry
          end
        end
        :success
      end
      @bot.conn.add_event(:QUIT, :remove_name_from_nicklist) do |msg, conn|
        nick = msg.prefix[/[^:!]+/]
        @bot.nicklist.each do |channel, sublist|
          entry = sublist.delete nick.dc
        end
        :success
      end
      @bot.conn.add_event(:MODE, :rescan_modes) do |msg, conn|
        channel = msg.params.first
        next if channel[0] != ?# 
        possibletargets = msg.params[2..-1]
        possibletargets.each do |target|
          next if target =~ /[#!@+]/
            next unless target =~ /\D/
          conn.send("NAMES #{channel}")
          break
        end
        :success
      end

      @bot.conn.add_event(:PRIVMSG, :date) do |msg, conn|
        next unless msg.params.last =~ /,date$/i
        target = msg.params.first
        @bot.msg(target, Time.now)
        :success
      end
      
      @bot.conn.add_event(:PRIVMSG, :del_quote) do |msg, conn|
        next unless msg.params.last =~ /\A!delquote /
        channel = msg.params.first
        next unless channel =~ /\A#/
          nick = msg.prefix[/[^:!]+/]
        next unless @bot.has_privilege? channel, nick or @bot.home_op? nick
        quoteid = msg.params.last[/\d+/].to_i
        with_db do |db|
          rows = d@bot.do("UPDATE quote SET deleted=1 WHERE id = ?", quoteid)
          if rows > 0
            @bot.notice(nick, "Quote with id #{quoteid} was deleted")
          else
            @bot.notice(nick, "Quote was not found")
          end
        end
        :success
      end

      @bot.conn.add_event(:PRIVMSG, :do_reconnect) do |msg, conn|
        target = msg.params.first
        nick = msg.prefix[/[^:!]+/]
        next if target =~ /#/
          next unless @bot.home_op? nick
        next unless msg.params.last =~ /\Areconnect/
        @bot.restart
      end

      @bot.conn.add_event(:PRIVMSG, :default) do |msg, conn|
        next unless msg.params.first !~ /#/
          nick = msg.prefix[/[^:!]+/]
        message = msg.params.last
        @bot.msg(@bot.home_channel, "/MSG: #{nick}  #{message}")
        :success
      end

    end
    
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
