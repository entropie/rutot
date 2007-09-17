#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  class Config

    module ConfigModules

      module Master

        attr_reader :daddy
        attr_reader :myself
        attr_reader :prefix

        def master(master)
          @daddy = master
        end

        def prefix(prfx = nil)
          @prefix = prfx if prfx
          @prefix
        end

        alias :bot_prefix :prefix

        def myself(arg = nil)
          @myself = arg if arg
          @myself
        end
      end

      module Server
        attr_reader :realname, :ident

        def ident(name = nil)
          @ident = name if name
          @ident
        end

        def real_name(name = nil)
          @realname = nil if name
          @realname = name
        end
      end

      module Freenode

        def freenode(password = nil)
          @freenode_password = password if password
          @freenode_password
        end

      end

      module Channels

        attr_reader :channels, :home_channel

        def home(chan)
          @home_channel = chan
        end

        def join(*args, &blk)
          @channels = Rutot::Channels.new(self)
          @channels.instance_eval(&blk)
          self
        end

        def channel(name, &blk)
          instance_eval(&blk)
          @channels << name
        end
      end

    end

  end
end
