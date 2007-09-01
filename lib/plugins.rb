#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  class Plugin
    attr_reader :channel, :name
    def initialize(file)
      @name = name
    end
    def channel=(chan)
      @channel = chan
    end
  end
  
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
    
    include Helper
    include KeywordArguments

    def include(pl)
      self.class.send(:include, Contribs[pl])
    end
    
    def map!
      self.bot.channels.each do |chan|
        self.bot.base_mods.each do |m|
          puts :PLG, "#{chan.name}: mapping defaultplugin #{m}"
          chan.plugins << m unless chan.plugins.include?(m)
        end

        chan.plugins.each do |plug|
          puts :PLG, "#{chan.name}: attaching #{plug}"
          plug = Plugin.new(plug)
          plug.channel = chan.name
          bot.mod(plug)
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
