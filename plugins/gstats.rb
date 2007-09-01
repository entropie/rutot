#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "yaml"

chans = ["#ackro", "#test", '#emacs', '#ruby']
sc = hlp_fbk('statschannel').definitions.map{ |sc| sc.text}
chans = sc if sc

respond_on(:PRIVMSG, :gstats, prefix_or_nick(:makestats), :args => [:Everything]) do |h|
  h.respond "recorded users for #{chans.join(', ')}.  "
  
  retthingy = { }
  nickc = 0

  chans.each do |chan|
    ich = chan
    idf = bot.channels.map{ |c| c.name }.include?(ich)
    unless idf
      h.bot.join(ich)
      sleep 60
    end
    p "stats for #{ich}"
    
    retthingy[ich] = nl = h.bot.nicklist[ich].keys
    nickc += nl.size
    h.bot.part(ich, 'Big brother is watching you.  This is a channel/user map bot.') unless idf
  end

  File.open(File.expand_path('~/Tmp/irc_map.yaml'), 'w+') do |yamlfile|
    yamlfile.write(YAML::dump(retthingy))
  end

  h.respond("Wrote %i nicks from %i channels.  #{`cat ~/Tmp/irc_map.yaml | rafb.rb`}" % [nickc, chans.size])
  
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
