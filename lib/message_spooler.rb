#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  class MessageSpooler < Array

    MaxLines = 4
    
    Element = Struct.new(:target, :lines)

    attr_reader :bot
    attr_reader :blocked
    attr_reader :quiet
    
    def initialize(bot, p = 0)
      @blocked = false
      @bot = bot
      @quiet = false
      @more = { }
      super()
    end

    def need_more?(ele)
      if ele.lines.size > MaxLines then true else false end
    end

    def more(target)
      ret = @more[target] if @more[target]
      @more[target] = nil
      ret
    end
    
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

    # Save entire message in spooler, replace beginning of
    # first line with timestamp and other lines with two
    # spaces.
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
    
    def quiet!
      @quiet = true
    end

    def talk!
      @quiet = false
      @bot.channels.each do |chan|
        unless @more[chan.name].nil?
          push(chan.name, "[Say ,more for %i skipped lines]" % @more[chan.name].lines.size) unless @more[chan.name].lines.empty?
        end
      end
      @quiet
    end

    def quiet?;   @quiet; end
    
    def blocked?; @blocked; end
    
    def push(target, *lines)
      puts :SPO, "REC: for #{target} : #{lines.to_s.size}bytes" unless lines.to_s.strip.size.zero?
      self << Element.new(target, lines)
    end

    def loop(&blk)
      until empty? and blocked?
        el = self.pop
        if el
          unless quiet?
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
