#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  module ConfigModules

    module Master
      attr_reader :daddy
      def master(master)
        @daddy = master
      end
    end
    
    module Server
      attr_reader :realname, :ident

      def ident(name)
        @ident = name
      end
      
      def realname(name)
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
    attr_reader :plugins
    
    def initialize(name)
      @name = name
      @plugins = Plugins.new
    end
    def plugin(name)
      @plugins.select(name.to_sym)
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
    
    # def map!
    #   each do |c|
    #     pp c
    #   end
    #   nil
    # end

  end
  
  class Config

    attr_reader   :configfile
    attr_reader   :nick
    attr_reader   :plugins

    attr_accessor :servername
    attr_accessor :port
    attr_accessor :channels

    def [](obj);    end
    
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
