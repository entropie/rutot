#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#
module Rutot
  module Events
    module EventHandler

      module Extended

        ORDER = 1

        def privmsg_date
          @bot.conn.add_event(:PRIVMSG, :date) do |msg, conn|
            next unless msg.params.last =~ /#{EventPrefix}date$/i
            target = msg.params.first
            @bot.msg(target, Time.now)
            :success
          end
        end

        def privmsg_fortune
          @bot.conn.add_event(:PRIVMSG, :fortune) do |msg, conn|
            next unless msg.params.last =~ /#{EventPrefix}fortune$/i
            target = msg.params.first
            @bot.msg(target, `fortune -s`.gsub("\n",''))
            :success
          end
        end

        def privmsg_reconnect
          @bot.conn.add_event(:PRIVMSG, :do_reconnect) do |msg, conn|
            target = msg.params.first
            nick = msg.prefix[/[^:!]+/]
            next unless @bot.daddy == nick
            next unless msg.params.last =~ /\Areconnect/
            @bot.restart
          end
        end
        
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
