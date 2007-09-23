#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author: Stefan Walk <stefan.walk@physik.tu-darmstadt.de>
#

class IRCClient

  attr_accessor :serverhost, :serverport, :nick, :ident, :realname

  attr_reader :conn, :currentnick

  def initialize
    @conn = IRCConnection.new
    @serverport = 6667
  end

  def connect
    @conn.add_event(:PING, :respond_to_ping) do |msg, conn|
      pong msg.rawparams
      :success
    end
    suffix = ""
    @conn.add_event(:ERR_NICKNAMEINUSE, :try_nicknames) do |msg, conn|
      if suffix == ""
        suffix = "-"
      elsif suffix == "-"
        suffix = "-1"
      else
        suffix = "-#{suffix[/\d+/].to_i + 1}"
      end
      set_nick @nick + suffix
      :success
    end
    @conn.add_event(:RPL_WELCOME, :fetch_nick) do |msg, conn|
      @currentnick = msg.params.first
      conn.remove_event(:RPL_WELCOME, :fetch_nick)
      :success
    end
    @conn.add_event(:RPL_WELCOME, :remove_welcome_events) do |msg, conn|
      conn.remove_event(:ERR_NICKNAMEINUSE, :try_nicknames)
      conn.remove_event(:RPL_WELCOME, :remove_welcome_events)
      :success
    end
    @conn.connect(@serverhost, @serverport)
    set_user @ident, @realname
    set_nick @nick
  end



  def join(channels)
    channels = [channels] if channels.is_a? String
    channels.each do |channel|
      self.send(:join_hook, channel) if self.respond_to?(:join_hook)
      @conn.send("JOIN #{channel}")
    end
  end


  def part(channels, str="")
    channels = [channels] if channels.is_a? String
    channels.each do |channel|
      self.send(:part_hook, channel) if self.respond_to?(:part_hook)
      @conn.send("PART #{channel} : #{str}")
    end
  end


  def set_nick(nickname)
    self.send(:nickchange_hook, nickname) if self.respond_to?(:nickchange_hook)
    @conn.send("NICK #{nickname}")
  end


  def raw(str)
    @conn.send(raw)
  end


  def whois(str)
    @conn.send("WHOIS #{str}")
  end


  def set_user(ident, realname)
    @conn.send("USER #{ident} 5 0 :#{realname}")
  end


  def mode(target, mode)
    @conn.send("MODE #{target} #{mode}")
  end


  def pong(params="")
    @conn.send("PONG #{params}".strip)
  end


  def msg(target, *args)
    args.flatten.each do |line|
      puts :SND, "#{target}  #{line}"
      @conn.send("PRIVMSG #{target} :#{line}")
    end
  end


  def notice(target, *args)
    args.flatten.each do |line|
      @conn.send("NOTICE #{target} :#{line}")
    end
  end


  def emote(target, *args)
    args.flatten.each do |line|
      ctcp(target, :ACTION, line)
    end
  end


  def ctcp(target, ctcp, content="")
    line = "#{ctcp} #{content}".strip
    @conn.send("PRIVMSG #{target} :\x01#{line}\x01")
  end


  def ping(str=nil)
    line = "PING"
    if str
      line << " :#{str}"
    end
    @conn.send(line)
  end


  def quit(str="")
    self.send(:quit_hook) if self.respond_to?(:quit_hook)
    @conn.send("QUIT :#{str}")
    @conn.disconnect
  end


  def loop(&block)
    if block_given?
      @conn.loop &block
    else
      @conn.loop {}
    end
  end

end
