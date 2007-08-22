#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, prefix_or_nick(:excuse)) do |h|
  h.respond(`fortune bofh-excuses`.gsub(/\n[^$]/, "  "))
end


respond_on(:PRIVMSG, prefix_or_nick(:fortune), :args => [:String]) do |h|
  s = if h.args.empty? then '' else
        if h.args.first =~ /^[a-zA-Z0-9\-]+$/
          "99% #{h.args.first}"
        else
          ''
        end
      end
  h.respond(`fortune drugs zippy -s chucknorris bofh-excuses wisdom fortunes #{s}`)
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
