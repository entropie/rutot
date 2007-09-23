#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  class MessageSpooler < Array

    MaxLines = 4

    # Contents of @mrore
    Element = Struct.new(:target, :lines)

    attr_reader :bot
    attr_reader :blocked
    attr_reader :quiet
    attr_reader :quiet_list

    def initialize(bot)
      @quiet_list = []
      @blocked = false
      @bot = bot
      @quiet = false
      @more = { }
      super()
    end

    # returns true if ele.lines > MaxLines
    def need_more?(ele)
      if ele.lines.size > MaxLines then true else false end
    end

    # return @more and clean it
    def more(target)
      ret = @more[target] if @more[target]
      @more[target] = nil
      ret
    end

    # strip message lines if needed and save rest in @more
    def make_more(ele, f = false)
      if need_more?(ele)
        lines =
          unless f
            ele.lines[MaxLines..-1]
          else
            ele.lines
          end
        m = @more[ele.target] = Element.new(ele.target, lines)
        nel = Element.new(ele.target, ele.lines[0..MaxLines-1])
        nel.lines.last << "  [#{m.lines.size} left, say ,more]" unless nel.lines.empty?
        nel
      else
        ele
      end
    end

    # Save entire message in spooler, replace beginning of first line
    # with timestamp and beginning of other lines with two spaces.
    #
    def push_more(el)
      @more[el.target] ||= Element.new(el.target, [])
      return nil if el.lines.to_s.strip.empty?
      el.lines.map!{ |l|
        if el.lines.first == l
          l.gsub!(/^/, "[At " + Time.now.strftime("%H:%M:%S] "))
        else
          l.gsub!(/^/, "  ")
        end
      }
      @more[el.target].lines.push(*el.lines)
    end

    # sets quiet for channel or overall if +channel+ is nil
    def quiet!(channel = nil)
      unless channel
        puts :SPL, "overall quiet"
        @quiet = true
      else
        puts :SPL, "#{channel} quiet"
        @quiet_list << channel
        true
      end
    end

    # sets talk for channel or overall if +channel+ is +nil+
    def talk!(channel = nil)
      unless channel
        @quiet = false
      else
        puts :SPL, "talking again in #{channel}"
        raise "not in list #{channel}" unless @quiet_list.delete(channel)
      end
    end

    # checks whether there are ommited lines, parse in every channel
    # or in specifc if +chan+ is non +nil+.
    def channel_more(chan = nil)
      if chan and not @bot.channels[chan].nil?
        push(chan, "[Say ,more for %i skipped lines]" % @more[chan].lines.size) if
          @more[chan] and not @more[chan].lines.empty?
      else
        @bot.channels.each do |chan|
          unless @more[chan.name].nil?
            push(chan.name, "[Say ,more for %i skipped lines]" % @more[chan.name].lines.size) unless
              @more[chan.name].lines.empty?
          end
        end
      end
    end

    # returns true if bot is set overall quiet or quiete for specific
    # channel if +channel+ is non +nil+
    def quiet?(channel = nil)
      unless channel
        @quiet
      else
        @quiet_list.include?(channel)
      end
    end

    # returns +@blocked+
    def blocked?
      @blocked
    end

    # push line to spooler
    def push(target, *lines)
      puts :SPO, "REC: for #{target} : #{lines.to_s.size}bytes" unless lines.to_s.strip.size.zero?
      self << Element.new(target, lines)
    end

    # reads message spooler and handles more stuff.
    def loop(&blk)
      until empty? and blocked?
        el = self.pop
        if el
          if not quiet? and not quiet?(el.target)
            yield make_more(el)  # return message for further processing
          else
            push_more(el)        # add message to @more because we’re forced to quiet
          end
        end
        sleep 0.1
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
