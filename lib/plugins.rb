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

  class DefaultPlugins < Plugins
  end
  
  class ChannelPlugins < Plugins
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
