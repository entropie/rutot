#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


timed_response(60*60, :fortune) do |h|
  h.respond(hlp_fortune)
end

respond_on(:PRIVMSG, :excuse, prefix_or_nick(:excuse)) do |h|
  h.respond(hlp_fortune(['bofh-excuses'], [:s], true))
end


respond_on(:PRIVMSG, :fortune, prefix_or_nick(:fortune), :args => [:String]) do |h|
  begin
    s =
      if h.args.empty? then '' else
        if h.args.first =~ /^[a-zA-Z0-9\-]+$/
          "80% #{h.args.first}"
        else ''
        end
      end
    f = hlp_fortune([s])
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
