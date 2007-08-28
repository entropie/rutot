#
#
# Author:  Michael Fellinger <m.fellinger@gmail.com>
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'open-uri'

class TryRuby
  def initialize
    @url = "http://tryruby.hobix.com/irb?cmd=%s"
    reload_session
  end

  def req code
    code.gsub!(/[^[:print:]]/, " ")
    code.gsub!(/[^a-zA-Z0-9.-]/){|c| "%%%x" % c.ord }
    resp = open(@url % code, "Cookie" => @session).read
    if resp == "An error has occured.  Try refreshing this page to reload your session.\n" or
        resp == "Your session has been closed, either due to inactivity or a bit of code which ran too long. Refresh the page and you can begin a new session.\n"
      reload_session
      retry
    end
    resp
  end

  def reload_session
    init = open(@url % "!INIT!IRB!")
    @session = init.meta["set-cookie"]
  end
end

try = TryRuby.new
respond_on(:PRIVMSG, :irb, prefix_or_nick(:irb, :eval), :args => [:Everything], :arg_req => true) do |h|
  try.reload_session if try.req("1") == ""
  h.respond try.req(h.args.join(' '))
  
end

respond_on(:PRIVMSG, :irbreset, prefix_or_nick(:irb_reset)) do |h|
  try.reload_session
  h.respond(ReplyBox.k)
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
