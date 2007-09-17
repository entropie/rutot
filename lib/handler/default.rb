#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot
  module Events
    module EventHandler

      module Default

        include Rutot::Helper::Database

        ORDER = 0

        def privmsg_default
          @bot.conn.add_event(:PRIVMSG, :default) do |msg, conn|
            next unless msg.params.first !~ /#/
              nick = msg.prefix[/[^:!]+/]
            message = msg.params.last
            @bot.msg(@bot.home_channel, "/MSG: #{nick}  #{message}")
            :success
          end
        end

        def namreply_add_names_to_nicklist
          @bot.conn.add_event(:RPL_NAMREPLY, :add_names_to_nicklist) do |msg, conn|
            nicks = msg.params.last
            channel = msg.params[-2]
            nicks.split.each do |nick|
              op = !!nick.gsub!(/@/,'')
              voice = !!nick.gsub!(/\+/,'')
              @bot.nicklist[channel.dc][nick.dc] = State.new(op, voice)
              @bot.update_nicklist(channel.dc)
              SeenList.add_or_update(channel.dc, nick.dc, '[JOIN]')
            end
            :success
          end
        end

        def join_add_name_to_nicklist
          @bot.conn.add_event(:JOIN, :add_name_to_nicklist) do |msg, conn|
            nick = msg.prefix[/[^:!]+/]
            channel = msg.params.first
            @bot.nicklist[channel.dc][nick.dc] = State.new(false, false)
            @bot.update_nicklist(channel.dc)
            SeenList.add_or_update(channel.dc, nick.dc, '[JOIN]')
            :success
          end
        end

        def part_remove_name_from_nicklist
          @bot.conn.add_event(:PART, :remove_name_from_nicklist) do |msg, conn|
            nick = msg.prefix[/[^:!]+/]
            channel = msg.params.first
            @bot.nicklist[channel.dc].delete nick.dc
            @bot.update_nicklist(channel.dc)
            SeenList.add_or_update(channel.dc, nick.dc, "[Part] "+msg.params.last)
            :success
          end
        end

        def kick_remove_name_from_nicklist
          @bot.conn.add_event(:KICK, :remove_name_from_nicklist) do |msg, conn|
            nick    = msg.params[1]
            channel = msg.params[0]
            @bot.nicklist[channel.dc].delete nick.dc
            @bot.update_nicklist(channel.dc)
            SeenList.add_or_update(channel.dc, nick.dc, "[Kick] "+msg.params.last)
            :success
          end
        end

        def quit_remove_name_from_nicklist
          @bot.conn.add_event(:QUIT, :remove_name_from_nicklist) do |msg, conn|
            begin
              nick = msg.prefix[/[^:!]+/]
              chan = nil
              @bot.nicklist.each do |channel, sublist|
                chan = channel
                entry = sublist.delete nick.dc
              end
              if chan
                @bot.update_nicklist(chan)
                SeenList.add_or_update(chan, nick.dc, "[Quit] "+msg.params.last)
              end
              :success
            rescue
              p $!
            end
          end
        end

        def mode_rescan_modes
          @bot.conn.add_event(:MODE, :rescan_modes) do |msg, conn|
            channel = msg.params.first
            next if channel[0] != ?#
            possibletargets = msg.params[2..-1]
            possibletargets.each do |target|
              next if target =~ /[#!@+]/
                next unless target =~ /\D/
              conn.send("NAMES #{channel}")
              break
            end
            :success
          end
        end

        def nick_move_name_in_nicklist
          @bot.conn.add_event(:NICK, :move_name_in_nicklist) do |msg, conn|
            nick = msg.prefix[/[^:!]+/]
            newnick = msg.params.last
            @bot.nicklist.each do |channel, sublist|
              entry = sublist.delete nick.dc
              if entry
                sublist[newnick.dc] = entry
              end
            end
            :success
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
