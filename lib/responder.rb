#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#
module Rutot
  class Plugins
    class RespondHandle

      attr_reader :type, :keywords, :options, :handler, :respond_msg, :name

      def initialize(type, keywords, options, &blk)
        @name = "#{type}:#{keywords}"
        @respond_msg = ''
        @type = type
        @keywords = keywords
        @handler = blk
        @options = options
        puts :RHA, "adding #{type}:#{keywords}"
      end

      def respond(msg)
        @respond_msg = msg
      end
      
      def args=(args)
        @args = args
      end
      
      def args
        @args
      end

      def parse_args
        o = @args.join(" ")
        o.gsub!(keywords, '').strip!
        o = o.split(" ")
        @args = []
        o.each_with_index{ |a, i|
          @args << case options[:args][i]
                   when :Integer:
                       Integer(a)
                   when :String:  a
                   else a
                   end
        }
        if @options[:args]
          @args = @args[0..(@options[:args].size-1)]
        else
          @args = @args
        end
        
      end
      
      def call(*args)
        @args = args
        parse_args
        @handler.call(self)
      end
      
    end
    
    class Responder < Array
      attr_reader :keywords
      def initialize
        @keywords = { }
      end
      
      def add(type, handler, options, &blk)
        rh = RespondHandle.new(type, handler, options, &blk)
        self << rh
      end
    end
    
    PluginDirectory = File.join(File.dirname(__FILE__), '..', 'plugins')

    attr_reader :responder
    def initialize
      @responder = Responder.new
    end

    def attach(name, con, bot)
      self.responder.each do |plugin|
        puts :PLG, "#{name}: attaching plugin: `#{plugin.name}´"
        con.add_event(plugin.type, plugin.name) do |msg, con|
          message = msg.params.last
          target = msg.params.first
          if message =~ plugin.keywords
            bot.msg(target, plugin.call(message))
          end
        end
      end
    end
    
    def respond_on(type, handler, options = { }, &blk)
      options.extend(ParamHash).
        process!(:args => :optional)
      @responder.add(type, handler, options, &blk)
    end
    
    def prefix(arg)
      /#{Events::EventPrefix} ?(#{arg.to_s})/
    end
    
    def select(name)
      Dir["#{PluginDirectory}/*.rb"].#
        grep(/#{name}\.rb$/).each { |pluginfile|
        puts :PLG, "loading #{pluginfile}"
        self.load(pluginfile)
      }
    end

    def load(plugin)
      eval(File.open(plugin).readlines.join, binding)
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
