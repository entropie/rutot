#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


respond_on(:PRIVMSG, /\?\?+$/) do |h|
  h.respond(ReplyBox.YO)
end


respond_on(:PRIVMSG, prefix(:fortune), :args => [:String]) do |h|
  s = if h.args.empty? then '' else
        p 22 if h.args =~ /^[a-zA-Z0-9\-]+$/
        if h.args.first =~ /^[a-zA-Z0-9\-]+$/
          "99% #{h.args.first}"
        else
          ''
        end
      end
  h.respond(`fortune drugs zippy -s chucknorris bofh-excuses wisdom fortunes #{s}`.gsub(/(\n|\t|\s+)/m, ' '))
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
