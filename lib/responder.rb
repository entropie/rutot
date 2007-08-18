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
        @type, @keywords, @handler, @options = type, keywords, blk, options
        puts :RHA, "adding #{type}:#{@keywords}"
      end

      def name=(name)
        @name = name
      end

      def respond(*msg)
        @respond_msg = msg.join(' ')
      end
      
      def args=(args)
        @args = args
      end

      def format_arguments
        rargs = @args.dup.join
        self.keywords.each do |kw|
          rargs.gsub!(kw, '')
        end
        rargs.strip.split(" ")
      end
      private :format_arguments
      
      def args
        @args
      end

      def keywords
        case @keywords
        when Array
          @keywords
        when Regexp
          [@keywords].flatten
        else
          @keywords.to_a
        end
      end

      
      def parse_args!
        args = format_arguments
        if @options[:args]
          if args.empty? and @options[:arg_req]
            raise "we want arguments"
          end

          @args = []
          @options[:args].each_with_index do |a, i|
            @args <<
              case options[:args][i]
              when :Integer: Integer(args[i])
              when :String : String(args[i])
              else
                args[i]
              end
          end
        else
          @args = []
        end
        true
      end
      
      def call(*args)
        @args = args
        parse_args!
        @handler.call(self)
      end
      
    end
    
    class Responder < Array

      def add(type, handler, options, &blk)
        rh = RespondHandle.new(type, handler, options, &blk)
        self << rh
        rh
      end

    end
    
    PluginDirectory = File.join(File.dirname(__FILE__), '..', 'plugins')

    attr_reader :responder
    attr_reader :bot

    def initialize(bot)
      @bot = bot
      reset
    end

    def load_plugin_files!
      bot.config.mods.each do |mod|
        select(mod)
      end
    end
    
    def reset
      @responder = Responder.new
    end

    def attach(name, con, bot)
      load_plugin_files!
      self.responder.each do |plugin|
        puts :PLG, "#{bot.nick}: attaching plugin: `#{plugin.name}´"
        con.add_event(plugin.type, plugin.name) do |msg, con|
          message = msg.params.last
          target = msg.params.first
          if plugin.keywords.any?{ |a| message =~ a }
            bot.msg(target, plugin.call(message))
          end
        end
      end
    end
    
    def respond_on(type, handler, options = { }, &blk)
      options.extend(ParamHash).
        process!(:args => :optional, :arg_req => :optional)
      @responder.add(type, handler, options, &blk)
    end
    
    def prefix(arg, h = 1)
      @prefix = Events::EventPrefix
      /#{@prefix*h} ?(#{arg.to_s})/
    end

    def prefix_or_nick(arg)
      rrgx = "^rutlov[:, ]+"
      rrgx += "(#{arg})"
      [prefix(arg), prefix(arg, 2), Regexp.new(rrgx)]
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
