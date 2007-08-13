#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  module ConfigModules
    
    module Freenode
      
      def freenode(password)
        self
      end
      
    end

    module Channels
      
      attr_reader :channels
      
      def join(*args, &blk)
        @channels = Rutot::Channels.new(self)
        instance_eval(&blk)
        self
      end

      def channel(name)
        @channels << name
      end
      
    end
    
  end

  class Channels < Array

    attr_accessor :server

    def initialize(server)
      @server = server
    end
    
  end
  
  class Config

    attr_reader   :configfile
    attr_reader   :nick

    attr_accessor :servername
    attr_accessor :port
    attr_accessor :channels

    def self.read(file, handler)
      klass = ConfigModules.constants.map{ |cl|
        ConfigModules.const_get(cl)
      }.inject(self.new(file, handler)) do |m, config_module|
        puts :INT, "adding module #{config_module}"
        m.extend(config_module)
      end
      klass.instance_eval(File.readlines(file).join)
      klass
    end

    def name(name)
      @nick = name
    end
    
    def initialize(configfile, handler)
      @configfile, @handler = configfile, handler
    end

    def Server(name, port = 6676, &blk)
      puts :CNF, "parsing section: Server(\"#{name}\")"
      instance_eval(&blk)
      self.servername = name
      self.port = port
      @handler << self.dup
      self
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
