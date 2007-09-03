#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'og'

module Rutot

  module Helper

    module Database

      Config = {
        #:destroy => true,
        :store => :sqlite,
        :name => 'keywords'
      }

      $DBG = true if $DEBUG

      class SeenList
        attr_accessor :channel, String
        attr_accessor :nick,    String
        attr_accessor :msg,     String
        attr_accessor :time,    Time
        def initialize(chan, nick)
          @channel, @nick, @msg, @time = chan, nick, '', Time.now
        end

        def self.add_or_update(chan, nick, msg = '')
          ret =
            if r = find_by_channel_and_nick(chan, nick)
              r.msg = msg unless msg.empty?
              r.time = Time.now
              r
            else
              r = create(chan, nick)
              r.msg = msg unless msg.empty?
              r
            end
          ret.save
        end
        
      end

      class ChannelStats
        attr_accessor :channel, :uniq => true
        attr_accessor :snapshot_date, Time, :uniq => true

        has_many      :channels, ChannelStat
        def initialize(channel = nil)
          @channel = channel
          @snapshot_date = Time.now
        end

        def self.clean
        end
      end

      class ChannelStat
        attr_accessor :usercount, Fixnum
        belongs_to    :channel_stats, ChannelStats

        def initialize(usercount = 0)
          @usercount = usercount
        end

      end
      
      
      class Definition
        attr_accessor :text, String, :uniq => true
        belongs_to    :keyword_bundle, KeywordBundle

        def initialize(text = nil)
          @text = text.to_s
        end
        
        def to_s
          return @text
        end
      end


      class KeywordBundle

        attr_accessor :keyword,       String, :uniq => true
        has_many      :definitions,   Definition

        def initialize(keyw = nil)
          @keyword = keyw.to_s
        end

        def get_at(ind)
          definitions.each_with_index{ |d, i|
            return d if i == ind
          }
          nil
        end
        
        def delete_at(ind)
          get_at(ind).delete
        rescue
          nil
        end

        def replace_at(ind, text)
          t = get_at(ind)
          t.text = text
          t.save
        rescue
          nil
        end
        
        def to_ary
          ds = []
          ret = []
          definitions.each_with_index{ |d, i|
            ds << [i, d]
          }
          ds.each do |n, d|
            ret <<
              if n.zero?
                "#{keyword}  [#{n}]  #{d.to_s}"
              else
                "[#{n}] #{d.to_s}"
              end
          end
          ret
        end

        def to_s
          @keyword
        end
        
      end

      Og.setup(Config)
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
