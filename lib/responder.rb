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
        :k =>           [:aight, :k, :done, :mhmk, :yup, :klar],
        :YO =>          ["YEAH!", 'Yo.', 'Definitely yes.', 'Sure.', 'You really don’t want to know it.'],
        :NO =>          ["Uh.", 'Hmm, nope.', 'We all gonna die down here.', '*Shrug*'],
        :SRY =>         [ proc{ "#{if $! then "Uhh, #{$!}.  " else '' end}Reason: %s" % `fortune bofh-excuses -s`.split("\n").last.to_irc_msg} ]
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

      attr_reader   :type, :keywords, :options, :handler, :respond_msg, :name, :raw
      attr_accessor :bot, :msg, :con, :channel

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

          if @options[:args].size == 1 and @options[:args].first == :Everything
            return @args << args
          end
          
          @options[:args].each_with_index do |a, i|
            @args <<
              case options[:args][i]
              when :Integer:  Integer(args[i])
              when :String :  String(args[i])
              when :Everything
                String(args[i..args.size-1].join(' '))
              end
          end
          @args.compact!
        else
          @args = []
        end
        true
      end

      def clear!
        @respond_msg, @msg, @con = [], nil, nil
      end
      
      def call(*args)
        @args = args
        @raw  = @args.dup
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
      a=bot.channels.inject([]) do |m, chan|
        m.push(*chan.plugins)
      end
      a.uniq.each do |mod|
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
      load_plugin_files!
      attach(@bot.conn, @bot)
    end

    def attach(con, bot)
      bot.channels.each do |chan|
        self.responder.each do |plugin|
          #next if  bot.config.base_mods.include?(plugin.name)
          
          puts :PLG, "#{bot.nick}:@#{chan.name} ATTACHING plugin: `#{plugin.name}´"
          con.add_event(plugin.type, plugin.name) do |msg, con|
            message = msg.params.last
            target = msg.params.first

            plugin.channel = msg.params.first
            plugin.msg = msg
            plugin.con = con

            tchan = bot.config.channels[plugin.channel]

            if(plugin && tchan && tchan.plugins.include?(plugin.name))
              if plugin.keywords.any?{ |a| message =~ a }
                puts :PLG, "#{message} matches #{plugin.name}"
                ret = parse_plugin_retval(plugin.call(message))
                bot.spooler.push(target, *ret)
              end
            elsif plugin.keywords.any?{ |a| message =~ a }
              puts :PLG, "#{message} matches #{plugin.name}"
              ret = parse_plugin_retval(plugin.call(message))
              bot.spooler.push(target, *ret)
            end
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
    
    def respond_on(type, name, handler, options = { }, &blk)
      options.extend(ParamHash).
        process!(:args => :optional, :arg_req => :optional)
      @responder.add(type, handler, options, &blk).name = name
    end
    
    def prefix(arg, h = 1)
      @prefix ||= Events::EventPrefix
      /#{@prefix*h} ?(#{arg.to_s})(?:$|\s+)/
    end

    def prefix_or_nick(*args)
      args.inject([]) do |m, arg|
        rrgx = "^#{bot.nick}[:, ]+"
        rrgx += "(#{arg})(?:$|\s+)"
        m << [prefix(arg), prefix(arg, 2), Regexp.new(rrgx)]
      end.flatten
    end

    def prefix_or_nick_r(rgx, arg)
      rrgx = "^#{bot.nick}[:, ]+"
      rrgx += "(#{rgx})(?:$|\s+)"
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
