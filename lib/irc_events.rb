#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#



module Rutot
  module Events

    State = Struct.new(:op, :voice)
    
    EventDirectory = File.dirname(__FILE__) + "/handler/"

    EventPrefix = ','
    
    class EventDispatcher

      attr_accessor :bot

      def initialize(bot)
        @bot = bot
      end
      
    end
    
    def self.map!
      puts :EDI, "mapping plugin modules for `#{bot.nick}´"
      bot.channels.each do |chan|
        chan.plugins.attach(chan.name, bot.conn, bot)
      end
    end

    def self.load_all!(bot)
      Dir["#{EventDirectory}*.rb"].each do |eventfile|
        load eventfile
      end

      puts :EDI, "preparing events for `#{bot.nick}´"
      ed = EventDispatcher.new(bot)
      
      Events::EventHandler.constants.
        map { |c| Events::EventHandler.const_get(c) }.
        sort_by{ |c| c::ORDER }.
        each { |handlermod|
        puts :EDI, "extending with `#{handlermod}´"
        ed.extend(handlermod)
        handlermod.instance_methods.sort.each { |im|
          puts :EDI, "", "adding #{im}"
          ed.send im
        }
      }
      ed
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
