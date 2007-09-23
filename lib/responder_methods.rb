#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  class Plugins

    class RespondHandle

      attr_reader   :type, :keywords, :options, :handler, :respond_msg, :name, :raw
      attr_accessor :bot, :msg, :con, :channel

      attr_accessor :global_name

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

      def args=(args)
        @args = args
      end

      def args
        @args
      end

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
        @respond_msg, @msg, @con, @args, @raw = [], nil, nil, [], []
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

    class Independent < Array

      class Sprog < RespondHandle

        attr_reader :name, :interval, :handler

        attr_accessor :last, :bot

        def initialize(name, interval, &blk)
          @name, @interval = name, interval
          @handler = blk
          @last = { }
        end

        def last
          @last
        end

        def call
          @args = @raw = []
          ret = @handler.call(self)
          self.clear!
          ret
        end

      end

      class DynamicResponder < Sprog
        def initialize(name, &blk)
          @name = name
          @handler = blk
        end
      end


      def select(responder)
        responder.select{ |r| r.name == name}
      end

      def initialize(bot)
        super()
        @bot = bot
      end

      def add_timed(interval, name, options = { }, &blk)
        sprog = Sprog.new(name, interval, &blk)
        sprog.bot = @bot
        self << sprog
      end

      def dynamic_response(name, &blk)
        sprog = Sprog.new(new, &blk)
      end

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
