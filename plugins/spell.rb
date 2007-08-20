#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, prefix_or_nick(:spell), :args => [:String]) do |h|
  if(h.args.empty? && h.args.first =~ /^\S+$/)
    h.respond(ReplyBox.NO)
  else
    pa = h.args.first
    io = IO.popen("ispell -a -S", "w+")
    if(io)
      io.puts pa
      io.close_write
      io.each_line {|l|
        if(l =~ /^\*/)
          h.respond "#{pa} may be spelled correctly"
        elsif(l =~ /^\s*&.*: (.*)$/)
          h.respond "#{pa}:  #$1"
        elsif(l =~ /^\s*\+ (.*)$/)
          h.respond "#{pa} is presumably derived from " + $1.dc
        elsif(l =~ /^\s*#/)
          h.respond "#{pa}: no suggestions"
        end
      }
      io.close
    else
      h.respond "couldn't exec ispell :("
    end
  end
end

