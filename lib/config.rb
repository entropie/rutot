#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  module ConfigModules

    module Master
      attr_reader :daddy
      attr_reader :myself
      def master(master)
        @daddy = master
      end

      def myself(arg = nil)
        @myself = arg if arg
        @myself
      end
    end
    
    module Server
      attr_reader :realname, :ident

      def ident(name=nil)
        @ident = name if name
        @ident
      end
      
      def realname(name=nil)
        @realname = nil if name
        @realname = name
      end
    end

    module Freenode

      def freenode(password)
        self
      end
      
    end

    module Channels
      
      attr_reader :channels, :home_channel

      def home(chan)
        @home_channel = chan
      end
      
      def join(*args, &blk)
        @channels = Rutot::Channels.new(self)
        @channels.instance_eval(&blk)
        self
      end

      def channel(name, &blk)
        instance_eval(&blk)
        @channels << name
      end

    end
    
  end

  class Channel

    attr_reader :name
    
    def initialize(name)
      @name = name
    end

  end
  
  class Channels < Array

    attr_accessor :server

    def initialize(server)
      @server = server
    end

    def channel(name, &blk)
      chan = Channel.new(name)
      chan.instance_eval(&blk)
      self << chan
    end
    
  end
  
  class Config

    attr_reader   :configfile
    attr_reader   :nick

    attr_accessor :plugins
    attr_accessor :servername
    attr_accessor :port
    attr_accessor :channels

    attr_reader   :mods
    
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
      @configfile, @handler, @mods = configfile, handler, []
    end

    def finish
      self
    end
    
    def modules(*mods)
      mods.each{ |m| mod(m) }
    end

    def mod(mod)
      @mods << mod
    end
    
    def Server(name, port = 6676, &blk)
      puts :CNF, "parsing section: Server(\"#{name}\")"
      self.plugins = Plugins.new(self)
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
