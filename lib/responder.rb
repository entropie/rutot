#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class String
  def to_irc_msg
    split("\n").reject{|r| r.strip.empty? }
  end
end

module Rutot

  class Plugins

    class ReplyBox
      Replies = {
        :k =>           [:aight, :k, :done],
        :YO =>          ["YEAH!", 'Yo.', 'Definitely yes.'],
        :NO =>          ["uh.", 'Hmm, nope.', 'We all gonna die down here.'],
        :SRY =>         [ proc{ "#{if $! then "Uhh, #{$!}  " else '' end}%s" % `fortune bofh-excuses`.split("\n").last.to_irc_msg} ]
      }

      def self.method_missing(m, *args, &blk)
        ar = Replies[m]
        ret = ar.sort_by{ rand }.first
        if ret.kind_of?(Proc)
          ret.call
        else
          ret
        end
      rescue
        "uh... #{$!}"
      end
    end
    
    class RespondHandle

      attr_reader   :type, :keywords, :options, :handler, :respond_msg, :name
      attr_accessor :bot

      def initialize(type, keywords, options, &blk)
        @name = "#{type}:#{keywords}"
        @respond_msg = []
        @type, @keywords, @handler, @options = type, keywords, blk, options
        puts :RHA, "adding #{type}:#{@keywords}"
      end

      def name=(name)
        @name = name
      end

      def respond(*msg)
        (@respond_msg ||= []) << msg.join("\n")
      end
      
      def args=(args); @args = args; end

      def args; @args; end


      def format_arguments
        rargs = @args.dup.join
        self.keywords.each do |kw|
          rargs.gsub!(kw, '')
        end
        rargs.strip.split(" ")
      end
      private :format_arguments
      

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
            raise "Error, This is not my fault dood, you forgot to instruct me correctly."
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

      def clear!
        @respond_msg = []
      end
      
      def call(*args)
        @args = args
        parse_args!
        ret = @handler.call(self)
        self.clear!
        ret
      end
      
    end
    
    class Responder < Array

      attr_reader :bot
      
      def initialize(bot)
        super()
        @bot = bot
      end
      
      def add(type, handler, options, &blk)
        rh = RespondHandle.new(type, handler, options, &blk)
        rh.bot = bot
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
      if @responder
        detach(@bot.conn, @bot)
        @responder.clear
      end
      @responder = Responder.new(bot)
    end

    def reload
      reset
      attach(@bot.conn, @bot)
    end

    def attach(con, bot)
      load_plugin_files!
      self.responder.each do |plugin|
        puts :PLG, "#{bot.nick}: ATTACHING plugin: `#{plugin.name}´"
        con.add_event(plugin.type, plugin.name) do |msg, con|
          message = msg.params.last
          target = msg.params.first
          if plugin.keywords.any?{ |a| message =~ a }
            puts :PLG, "#{message} matches #{plugin.name}"
            ret = parse_plugin_retval(plugin.call(message))
            bot.spooler.push(target, *ret)
          end
        end
      end
    end

    def parse_plugin_retval(pret)
      pret.to_s.to_irc_msg
    end
    private :parse_plugin_retval
    

    def detach(con, bot)
      load_plugin_files!
      self.responder.each do |plugin|
        puts :PLG, "#{bot.nick}: DETACHING plugin: `#{plugin.name}´"
        con.remove_event(plugin.type, plugin.name)
      end
    end
    
    def respond_on(type, handler, options = { }, &blk)
      options.extend(ParamHash).
        process!(:args => :optional, :arg_req => :optional)
      @responder.add(type, handler, options, &blk)
    end
    
    def prefix(arg, h = 1)
      @prefix ||= Events::EventPrefix
      /#{@prefix*h} ?(#{arg.to_s})/
    end

    def prefix_or_nick(*args)
      args.inject([]) do |m, arg|
        rrgx = "^rutlov[:, ]+"
        rrgx += "(#{arg})"
        m << [prefix(arg), prefix(arg, 2), Regexp.new(rrgx)]
      end.flatten
    end

    def prefix_or_nick_r(rgx, arg)
      rrgx = "^rutlov[:, ]+"
      rrgx += "(#{rgx})"
      [Regexp.new(rrgx)]
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
