#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#
#require 'pp'
#require "/home/mit/rand.rb"
#include :rand


module Rutot

  class Answers < Array

    attr_reader :args, :prefix, :suffix, :content, :attach
    class AnswersVariables
      def initialize(*args)
        @args, @prefix, @suffix, @attach = args, [], [], ''
        @content = []
      end

      def to_s(m)
        s = ''
        pr = prefix.pick_with_index
        s << m.to_s.first.strip % @args
        s << ' '
        if pr.first == ':empty:'
          s << content[pr.last-1].pick
        else
          s << pr.first
          s << ' '
          s << content[pr.last].pick
        end
        unless (r = @attach.scan(/#{pr.last+1}:\w+/)).empty?
          s << " " << r.to_s.gsub(/(\d:)/, '')
        end
        s << " " << m.to_s.last
        s
      end

      def method_missing(m, *a, &b)
        case m
        when :prefix:   @prefix.push(*a.flatten)
        when :suffix:   @suffix.push(*a.flatten)
        when :content:  @content.push(*a)
        when :attach:   @attach = a.join(' ')
        else
          if m.to_s =~ /^content_(\d+)/
            @content[$1.to_i-1] = a.flatten
          else
            super
          end
        end
      end
    end

    attr_reader :base_msg
    attr_reader :message

    def initialize(base_msg = '', &blk)
      @message = []
      @base_msg = base_msg
      @variables = { }
      instance_eval(&blk)
    end

    def message(msg) # !> method redefined; discarding old message
      @message << msg << " %s "
    end

    def variables(*args, &blk)
      av = @variables[args.to_s] ||= AnswersVariables.new(*args)
      av.instance_eval(&blk)
    end

    def test
      @variables.map do |v|
        v.last.to_s(self)
      end
    end

    def make
      @variables.pick.last.to_s(self)
    end

    def to_s
      [@message[0..-3].to_s, @message.last(2).first]
    end
  end
end


a = Rutot::Answers.new do
  message "ich will sagen das"

  variables 'er' do
    prefix    %w'eine ein :empty:'
    content_1 %w'tussi'
    content_2 %w'depp vollidiot'
    content_3 %w'kagge ist'
  end

  variables 'sie' do
    prefix    %w'eine eine'
    content_1 %w'bekloppte'
    content_2 %w'otze'
    attach    %w'2:frotze'
  end

  variables 'es' do
    prefix    %w'eine'
    content_1 %w'schande sheisse'
  end

  message "ist"
end

pp a.test



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end

