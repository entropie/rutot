#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  class Connections < Array
    def <<(cntccls)
      con = Connection.new(cntccls)
      puts :CON, "connection handle `%s´ saved" % con.config.servername
      puts :CHN, " -> #{con.config.channels.join(', ')}"
      push(con)
      con
    end

    def to_s
      inject([]) { |m, obj|
        m << "%-20s %s" % [obj.config.servername, obj.config.channels.join(', ')]
      }.join("\n")
    end
    
  end
  
  class Connection

    attr_reader :config, :connected

    def initialize(config)
      @config, @connected = config, false
    end

    def connect; end
    
    def server; config.servername; end
    def port  ; config.port;       end

  end
  
  class Daemon

    include Helper

    include KeywordArguments
    
    DefaultOptions = {
      :config_file => File.expand_path('~/.rutotrc.rb')
    }

    attr_reader :connections

    def <<(connection)
      @connections << connection
    end
    
    def initialize
      @connections = Connections.new
    end
    
    def self.run?; false; end

    def self.start(options = { })
      options.extend(ParamHash).process!(:config_file => :optional)
      options[:config_file] ||= DefaultOptions[:config_file]
      daemon = self.new
      __run__(options, daemon)
      daemon
    end

    def self.__run__(options, handler)
      options.extend(ParamHash).process!(:config_file => :required)
      userconfig = Config.read(options[:config_file], handler)
      rutlov = Rutlov.new(options)
      rutlov.config = userconfig
      rutlov
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
