#
#
# Author:  Michael Fellinger <m.fellinger@gmail.com>
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class TryRuby

  class ReloadException < Exception; end
  
  def initialize
    @url = "http://tryruby.hobix.com/irb?cmd=%s"
    reload_session
  end

  def req code
    begin
      code.gsub!(/[^[:print:]]/, " ")
      code.gsub!(/[^a-zA-Z0-9.-]/){|c| "%%%x" % c.ord }
      resp = open(@url % code, "Cookie" => @session).read
      if resp == "An error has occured.  Try refreshing this page to reload your session.\n" or
          resp == "Your session has been closed, either due to inactivity or a bit of code which ran too long. Refresh the page and you can begin a new session.\n"
        reload_session
        raise ReloadException, "session dead"
      end
    rescue ReloadException => e
      retry
    end
    resp
  end

  def reload_session
    init = open(@url % "!INIT!IRB!")
    @session = init.meta["set-cookie"]
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
