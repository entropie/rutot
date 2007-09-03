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
    
    def make_more(ele)
      if need_more?(ele)
        lines = ele.lines[MaxLines..-1]
        @more[ele.target] = Element.new(ele.target, lines)
        nel = Element.new(ele.target, ele.lines[0..MaxLines-1])
        nel.lines << "say ,more" unless nel.lines.empty?
        nel
      else
        ele
      end
    end
    
    def quiet!; @quiet = true;  end
    def talk!;  @quiet = false; end
    def quiet?; @quiet;         end
    
    def blocked?
      @blocked
    end
    
    def push(target, *lines)
      if quiet?
        puts :Q, "I’am not allowed to talk." if $DEBUG
        return
      elsif lines.to_s.size.zero?
        puts :SPO, "REC: empty string; ignoring" if $DEBUG
        return
      end
      puts :SPO, "REC: for #{target} : #{lines.to_s.size}bytes"
      self << Element.new(target, lines)
    end

    def loop(&blk)
      until empty? and blocked?
        el = self.pop
        if el
          yield make_more(el)
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
