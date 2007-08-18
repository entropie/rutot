#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Rutlov < IRCClient
  NICK = :config
  NAME = :config
  IDENT = :config
  CHANNELS = :config
  HOME_CHANNEL = :config
  IRC_HOSTS = :config
  
  # Config releated only to current bot instance.
  attr_accessor :config
  # server connections
  attr_accessor :connections
  attr_accessor :ircc
  attr_reader   :nicklist
  attr_accessor :channels
  attr_accessor :home_channel
  attr_reader   :nicklist
  attr_reader   :daddy

  attr_accessor :plugins
  
  def initialize(config)
    @serverport = config.port
    @serverhost = config.servername
    @nick       = config.nick
    @plugins    = Plugins.new(self)
    @ident      = config.ident
    @realname   = config.realname
    @channels   = config.channels
    @home_channel = config.home_channel
    @daddy      = config.daddy
    super()

    @config = config
    
    @nicklist = Hash.new{|h,k|h[k]={}}

    @conn.add_codes IRCConnection::ReplyCodes::RFC2812

    @conn.add_event :RPL_ENDOFMOTD, :join_channels do |msg, conn|
      join @channels.map{ |c| c.name}
      conn.remove_event :RPL_ENDOFMOTD, :join_channels 
      :success
    end

    @last_ping_time = Time.now
    @last_pong_time = Time.now

    Thread.start do
      sleep 30
      if @last_ping_time - @last_pong_time > 45
        restart
      end
      ping("keepalive")
      @last_ping_time = Time.now
    end

    @conn.add_event(:PONG, :keepalive) do
      @last_pong_time = Time.now
      :success
    end
  end

  def has_voice?(chan, nick)
    begin
      !!@nicklist[chan.dc][nick.dc].voice
    rescue NoMethodError
      false
    end
  end

  def has_op?(chan, nick)
    begin
      !!@nicklist[chan.dc][nick.dc].op
    rescue NoMethodError
      false
    end
    true
  end

  def has_privilege?(chan, nick)
    #has_op?(chan, nick) or has_voice?(chan, nick)
    true
  end

  def home_op?(nick)
    has_op?(home_channel, nick)
  end

  def restart
    quit("lata")
    exec("ruby "+__FILE__)
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
