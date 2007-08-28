#
#
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
    if resp == "An error has occured.  Try refreshing this page to reload your session.\n"
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
# p try.req(%{"Hello, World!"})
# p try.req(%{"1 + 12"})

try = TryRuby.new
respond_on(:PRIVMSG, :irb, prefix_or_nick(:irb), :args => [:Everything], :arg_req => true) do |h|
  h.respond try.req(h.args.join(' '))
end

# p try.req(%{:a}).strip
# p try.req(%{1+2}).strip

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
