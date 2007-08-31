#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "yaml"

chans = ["#ackro", "#test"]

respond_on(:PRIVMSG, :gstats, prefix_or_nick(:makestats), :args => [:Everything]) do |h|
  Thread.new { 

    retthingy = { }
    nickc = 0

    sc = hlp_fbk('statschannel').definitions.map{ |sc| sc.text}
    chans = sc if sc
    
    chans.each do |chan|
      ich = chan
      idf = bot.channels.map{ |c| c.name }.include?(ich)
      unless idf
        h.bot.join(ich)
        sleep 10
      end
      retthingy[ich] = nl = h.bot.nicklist[ich]
      nickc += nl.size
      h.bot.part(ich, 'Big brother is watching you.  This is a channel/user map bot.') unless idf
    end

    File.open(File.expand_path('~/Tmp/irc_map.yaml'), 'w+') do |yamlfile|
      yamlfile.write(YAML::dump(retthingy))
    end

    msg = retthingy.map{ |c, nicks|
      "#{c}: #{nicks.size}"
    }

    h.bot.spooler.push(h.channel, "Wrote %i nicks from %i channels.  #{`cat ~/Tmp/irc_map.yaml | rafb.rb`}" % [nickc, chans.size])
    #h.bot.spooler.push(h.channel, *msg)
  }
  
  h.respond "recording users for #{chans.join(', ')}"
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
