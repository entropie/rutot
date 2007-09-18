#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
# Author:  Christian Neukirchen <chneukirchen@gmail.com>
#

require "yaml"
require 'open-uri'

include :rafb

chans = ["#ackro", "#test", '#emacs', '#ruby']

def make_graph(uri)
  channels, ret = {}, ''
  uri.gsub!(/html$/, 'txt')

  ret << "graph {maxiter=5000; splines=true\n"
  channels = YAML::load(open(uri).read)

  colors = {
    60 => 'red',
    58 => 'violetred1',
    56 => 'violetred3',
    54 => 'orangered2',
    52 => 'palevioletred2',
    50 => 'orchid',
    45 => 'navajowhite3',
    42 => 'moccasin',
    38 => 'mediumorchid4',
    34 => 'maroon4',
    30 => 'lightskyblue3',
    27 => 'lightsalmon2',
    25 => 'lightcyan4',
    20 => 'lemonchiffon4'
  }
  
  channels.sort.each { |channel1, users1|

    n = 6*(1+Math.log(users1.size+1))
    color = colors.sort.reverse.select{ |i, c| i <= n }.flatten.first(2).last || 'peachpuff'
    ret << %{"#{channel1}" [ label="#{channel1}: #{users1.size}",center="true",fontcolor="black",style="rounded,filled",shape="diamond",fillcolor=#{color}, color=#{color},fontsize="#{6*(1+Math.log(users1.size+1))}"];} << "\n"
    
    channels.sort.each { |channel2, users2|
      break  if channel1 <= channel2
      unless (users1 & users2).empty?
        common = (users1 & users2).size / [users1.size, users2.size].min.to_f

        s =
          case
          when common > 0.55
            ["bold", "violetred4"]
          when common > 0.30
            ["bold", "mediumvioletred"]
          when common > 0.20
            ["bold", "lightseagreen"]
          when common > 0.10
            ["solid", "khaki3"]
          when common > 0.07
            ["solid", "slategray4"]
          when common > 0.04
            ["dashed", "snow3"]
          when common > 0.02
            ["dashed", "snow1"]
          else
            ["invis", "lightslategrey"]
          end

        weight = 1.666 ** (users1 & users2).size

        ret << %{"#{channel1}" -- "#{channel2}" [fillcolor=#{s.first}, color="#{s.last}", style=#{s.first}, weight=#{weight.to_s[0..12].to_f}];}
        ret << "\n"
      end
    }
  }

  ret << "}"
  ret

  File.open('/tmp/rutot_graph', 'w+') do |f|
    f.write(ret)
  end
  
  puts "making graphs..."
  `fdp /tmp/rutot_graph -o /tmp/rutot_graph_out.dot`
  `fdp -Tpng /tmp/rutot_graph_out.dot -o /tmp/rutot_graph.png`
  g2 = "/home/mit/public_html/rutot_graph_#{t=Time.now.to_i}.png"
  `cp /tmp/rutot_graph.png /home/mit/public_html/`
  `cp /tmp/rutot_graph.png #{g2}`
  puts "done making graphs."
  return ['http://ackro.ath.cx/~mit/rutot_graph.png', "http://ackro.ath.cx/~mit/rutot_graph_#{t}.png"]
end

respond_on(:PRIVMSG, :pastestats, prefix_or_nick(:pastestats)) do |h|
  h.respond(Rafb.new(h.bot.nick, 'freenode channel/usermap (YAML format)',
           File.open('/home/mit/Tmp/irc_map.yaml').
           readlines.join).paste)
end

respond_on(:PRIVMSG, :gstats, prefix_or_nick(:makestats), :args => [:Everything]) do |h|
  retthingy = { }
  nickc = 0
  begin
    chans = hlp_fbk('statschannel').definitions.map{ |sc| sc.text}
    #chans = ['#ackro', '#ruby-de']
    chans.each do |chan|
      ich = chan
      idf = bot.channels.map{ |c| c.name }.include?(ich)
      puts "stats for #{ich}"
      unless idf
        h.bot.join(ich)
        h.bot.spooler.quiet!(ich)
        si = 60*(3+(rand*10)).divmod(1).first
        p :GST, "sleep %i " % [si]
        sleep si
      end

      nl = h.bot.nicklist[ich]
      nl.delete(bot.nick)
      
      retthingy[ich] = nl.keys
      nickc += nl.size
      unless idf
        h.bot.part(ich, 'I’d try to map the user of various irc channels.  Infos in #ackro.')
        h.bot.spooler.talk!(ich)
      else
        h.bot.spooler.channel_more(ich)
      end
    end
    
    File.open(File.expand_path('~/Tmp/irc_map.yaml'), 'w+') do |yamlfile|
      yamlfile.write(YAML::dump(retthingy))
    end
    
    uri = "#{uri = `cat ~/Tmp/irc_map.yaml | rafb.rb`}".gsub(/"/, '').strip
    graph = make_graph(uri)
    if h.args.flatten.join.strip == 'polis'
      fb = "[:img]\n#{graph.last}\n[:img_end]\n\n"
      `echo "#{fb}" | ackro po way pipe to image`
      h.respond("Postet to polis.\n")
    end
    h.respond(str=("Wrote %i nicks from %i channels.  #{uri} — #{graph.first}" % [nickc, chans.size]))
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
