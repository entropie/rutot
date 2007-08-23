#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  class Connections < Array
    
    def <<(cntccls)
      con = Connection.new(cntccls)
      puts :CON, "connection handle `%s@%s´ saved" % [con.config.nick, con.config.servername]
      con.config.channels.map{ |c| puts :CHN, "", "%20s -> [%s]" % [c.name, c.plugins.join(',')]}.join("\n")
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
        connection.connected = true
      end
    end
    
  end
  
  class Connection

    attr_accessor :config, :connected, :bot

    include Events
    
    def initialize(config)
      @config, @connected = config, false
    end

    def connect!(bot)
      @bot = bot
      Events.load_all!(@bot)
      @bot.plugins.load_plugin_files!
      @bot.plugins.attach(@bot.conn, @bot)
      @bot.plugins.attach_defaults(@bot.conn, @bot)
      @bot.connect
      @bot.loop
    end
    
    def server; config.servername; end
    def port  ; config.port;       end

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
