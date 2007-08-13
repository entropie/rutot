#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  class Connection

    attr_reader :config, :connected
    
    def initialize(config)
      @config = config
      @connected = false
    end

    def connect
    end
    
    def server; config.servername; end
    def port  ; config.port;       end
    
    def self.<<(cntccls)
      con = self.new(cntccls)
      puts :CON, "connection handle `%s´ saved" % con.server
      puts :CHN, " -> #{con.config.channels.join(', ')}"
    end
    
  end
  
  module Daemon

    include Helper
    include KeywordArguments
    
    DefaultOptions = {
      :config_file => File.expand_path('~/.rutotrc.rb')
    }

    def self.run?; false; end

    def self.start
      __run__(DefaultOptions)
    end

    def self.__run__(options)
      options.extend(ParamHash).process!(:config_file => :required)
      userconfig = Config.read(options[:config_file])
      rl = Rutlov.new(options).extend(self)
      rl.config = userconfig
      rl.start
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
