#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  class Daemon
    include Contribs[:baldur]
    #include Contribs[:baldur]
    include Helper

    include KeywordArguments
    
    DefaultOptions = {
      :config_file => File.expand_path('~/.rutotrc.rb')
    }

    attr_accessor :connections

    def <<(connection)
      @connections << connection
    end
    
    def initialize
      @connections = Connections.new
    end

    def self.run?
      false
    end
    
    def self.start(options = { })
      options.extend(ParamHash).process!(:config_file => :optional)
      
      options[:config_file] ||= DefaultOptions[:config_file]
      daemon = self.new
      bot = __run__(options, daemon)
      daemon.connections = Connections.connect_all(daemon, bot)
      daemon
    end

    def self.__run__(options, handler)
      options.extend(ParamHash).process!(:config_file => :required)
      
      userconfig = Config.read(options[:config_file], handler)
      IRCConnection.debuglevel.network = true
      rutlov = Rutlov.new(userconfig)
      rutlov.load_plugins
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
