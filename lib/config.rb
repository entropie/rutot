#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  class Channel

    attr_reader :name
    attr_reader :whitelist
    attr_reader :blacklist
    attr_reader :plugins 
    attr_reader :independent

    attr_reader :responder
    
    attr_accessor :last_msg_time

    attr_accessor :prefix
    attr_accessor :nicks

    attr_accessor :keywords
    
    def modules(*mods)
      mods.each{ |m| @mods << m }
    end

    def whitelist(*args)
      @whitelist.push(*args)
    end

    def modules(*mods)
      @plugins.push(*mods)
    end

    def independent(*mods)
      @independent.push(*mods)
    end
    
    def initialize(name)
      @keywords = { }
      @mods = []
      @nicks = { }
      @last_msg_time = Time.now
      @responder, @plugins, @independent, @name, @whitelist, @blacklist =
        [], [], [], name, [], []
    end

  end
  
  class Channels < Array

    attr_accessor :server

    def [](nam)
      self.select{ |n| n.name.to_sym == nam.to_sym}.shift
    end
    
    def initialize(server)
      @server = server
    end

    def channel(name, &blk)
      chan = Channel.new(name)
      chan.instance_eval(&blk) if block_given?
      self << chan
    end
    
  end
  
  class Config

    attr_reader   :configfile
    attr_reader   :nick, :mods, :configfile

    attr_accessor :plugins, :servername, :port, :channels, :base_mods
    
    def self.read(file, handler)
      klass = ConfigModules.constants.map{ |cl|
        ConfigModules.const_get(cl)
      }.inject(self.new(file, handler)) do |m, config_module|
        puts :INT, "adding module #{config_module}" #if $DEBUG
        m.extend(config_module)
      end
      klass.instance_eval(File.readlines(file).join)
      klass
    end

    def base_mods
      @base_mods.select{ |bm| bm.kind_of?(Symbol)}
    end
    
    def name(name)
      @nick = name
    end
    
    def initialize(configfile, handler)
      @configfile, @handler, @mods, @base_mods = configfile, handler, [], []
    end

    def finish
      plugins.map!
      self
    end
    
    def mod(*mods)
      mods.each{ |m|
        @base_mods << m
      }
      @base_mods
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
