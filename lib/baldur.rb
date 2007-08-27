#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


module Rutot

  class MessageSpooler < Array

    Element = Struct.new(:target, :lines)
    
    attr_reader :bot
    attr_reader :blocked
    attr_reader :quiet
    
    def initialize(bot, p = 0)
      @blocked = false
      @bot = bot
      @quiet = false
      super()
    end

    def quiet!; @quiet = true;  end
    def talk!;  @quiet = false; end
    def quiet?; @quiet;         end
    
    def blocked?
      @blocked
    end
    
    def push(target, *lines)
      if quiet?
        puts :Q, "I’am not allowed to talk."
        return
      elsif lines.to_s.size.zero?
        puts :SPO, "REC: empty string; ignoring"
        return
      end
      puts :SPO, "REC: for #{target} : #{lines.to_s.size}bytes"
      self << Element.new(target, lines)
    end

    def loop(&blk)
      until empty? and blocked?
        el = self.pop
        yield el if el
        sleep 0.1
      end
    end
    
  end
  
  class Rutlov < IRCClient

    attr_accessor :config
    attr_accessor :connections
    attr_accessor :plugins
    attr_accessor :ircc
    attr_accessor :channels
    attr_accessor :home_channel

    attr_reader   :nicklist
    attr_reader   :message_spooler
    alias         :spooler :message_spooler
    attr_reader   :nicklist
    attr_reader   :daddy
    attr_reader   :ident
    attr_reader   :realname
    
    def initialize(config)
      @serverport      = config.port
      @serverhost      = config.servername
      @nick            = config.nick
      @ident           = config.ident
      @channels        = config.channels
      @home_channel    = config.home_channel
      @daddy           = config.daddy
      @realname        = 'Rutlov Übermorgen'
      @message_spooler = MessageSpooler.new(self)
      @plugins         = Plugins.new(self)
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
          #restart
        end
        ping("keepalive")
        @last_ping_time = Time.now
      end

      @conn.add_event(:PONG, :keepalive) do
        @last_pong_time = Time.now
        :success
      end

      Thread.abort_on_exception = true

      Thread.start do
        sleep 20
        Kernel.loop do
          @plugins.handle_independent_things!
        end
      end

      Thread.start do
        @message_spooler.loop do |ele|
          msg(ele.target, ele.lines)
        end
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


end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
