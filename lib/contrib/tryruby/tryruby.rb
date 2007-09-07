#
#
# Author:  Michael Fellinger <m.fellinger@gmail.com>
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class TryRuby
  RELOADER = [
  "An error has occured. Try refreshing this page to reload your session.\n",
  "Your session has been closed, either due to inactivity or a bit of code which ran too long. Refresh the page and you can begin a new session.\n"
  ]

  class ReloadFailure < RuntimeError; end

  def initialize
    @url = "http://tryruby.hobix.com/irb?cmd=%s"
    reload_session
  end

  def eval(code)
    code = code
    response = open(@url % urlify(code), "Cookie" => @session).read

    raise ReloadFailure, response if RELOADER.include?(response)
    response
  rescue ReloadFailure => ex
    p :TRY, ex
    reload_session
    retry
  end

  def reload_session
    init = open(@url % "!INIT!IRB!")
    @session = init.meta["set-cookie"]
    eval("$KCODE = 'u'")
  end

  def urlify(string)
    string.gsub(/([^ a-zA-Z0-9_.-]+)/n){|m|
      "%" + m.unpack('H2' * m.size).join('%').upcase
    }.gsub(' ', '+')
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
