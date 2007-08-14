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

    def self.connect_all
      Contribs['baldur'].class
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

  
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
