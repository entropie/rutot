#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :excuse, prefix_or_nick(:excuse)) do |h|
  h.respond(`fortune bofh-excuses`.gsub(/\n[^$]/, "  "))
end


respond_on(:PRIVMSG, :fortune, prefix_or_nick(:fortune), :args => [:String]) do |h|
  begin
  s = if h.args.empty? then '' else
        if h.args.first =~ /^[a-zA-Z0-9\-]+$/
          "99% #{h.args.first}"
        else ''
        end
      end
  f = `fortune -s drugs zippy futurama tao chucknorris bofh-excuses wisdom fortunes #{s}`
  unless f.empty?
    h.respond(f)
  else
    raise "No fortunes found"
  end
  rescue
    h.respond(ReplyBox.SRY)
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
