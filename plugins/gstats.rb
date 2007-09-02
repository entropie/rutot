#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
# Author:  Christian Neukirchen <chneukirchen@gmail.com>
#

require "yaml"
require 'open-uri'

chans = ["#ackro", "#test", '#emacs', '#ruby']

def make_graph(uri)
  channels, ret = {}, ''
  uri.gsub!(/html$/, 'txt')

  ret << "graph { splines = true; maxiter=5000; \n"
  channels = YAML::load(open(uri).read)

  channels.sort.each { |channel, users|
    ret << %{"#{channel} (#{channel.size})" [fontsize=#{6*(1+Math.log(users.size+1))}];} << "\n"
  }

  channels.sort.each { |channel1, users1|
    channels.sort.each { |channel2, users2|
      break  if channel1 <= channel2
      unless (users1 & users2).empty?
        common = (users1 & users2).size / [users1.size, users2.size].min.to_f

        case
        when common > 0.45
          s = "bold"
        when common > 0.25
          s = "solid"
        when common > 0.10
          s = "dotted"
        else
          s = "invis"
        end

        weight = 1.333 ** (users1 & users2).size

        ret << %{"#{channel1}" -- "#{channel2}" [style=#{s},weight=#{weight}];}
        ret << "\n"
      end
    }
  }

  ret << "}"
  ret

  File.open('/tmp/rutot_graph', 'w+') do |f|
    f.write(ret)
  end
  `fdp /tmp/rutot_graph -o /tmp/rutot_graph_out.dot`
  `dot -Tpng /tmp/rutot_graph_out.dot -o /tmp/rutot_graph.png`
  `cp /tmp/rutot_graph.png /home/mit/public_html/`
  return 'http://ackro.ath.cx/~mit/rutot_graph.png'
end



respond_on(:PRIVMSG, :gstats, prefix_or_nick(:makestats), :args => [:Everything]) do |h|
  retthingy = { }
  nickc = 0
  begin
    h.bot.spooler.quiet!
    chans = hlp_fbk('statschannel').definitions.map{ |sc| sc.text}
    chans.each do |chan|
      ich = chan
      idf = bot.channels.map{ |c| c.name }.include?(ich)
      unless idf
        h.bot.join(ich)
        sleep 60*5
      end
      puts "stats for #{ich}"
      
      nl = h.bot.nicklist[ich]
      nl.delete(bot.nick)
      
      retthingy[ich] = nl.keys
      nickc += nl.size
      h.bot.part(ich), 'I’d try to map the user of various irc channels.  Infos in #ackro.') unless idf
    end

    h.bot.spooler.talk!
    
    File.open(File.expand_path('~/Tmp/irc_map.yaml'), 'w+') do |yamlfile|
      yamlfile.write(YAML::dump(retthingy))
    end
    uri = "#{uri = `cat ~/Tmp/irc_map.yaml | rafb.rb`}".gsub(/"/, '').strip
    h.respond("Wrote %i nicks from %i channels.  #{uri} — #{make_graph(uri)}" % [nickc, chans.size])
  rescue
    p $!
    pp $!.backtrace
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
