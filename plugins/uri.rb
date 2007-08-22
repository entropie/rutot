#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'hpricot'
require 'open-uri'

def fetch(uri_str, limit = 10)
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  response = Net::HTTP.get_response(URI.parse(uri_str))
  case response
  when Net::HTTPSuccess     then response
  when Net::HTTPRedirection then fetch(response['location'], limit - 1)
  else
    response.error!
  end
end

respond_on(:PRIVMSG, /https?:\/\//, :args => [:Everything]) do |h|
  begin
    uri = URI.extract(h.raw.to_s).to_s
    case fetch(uri).content_type
    when /text\/\w+/
      str =
        if rand < 0.5
          "Hpricot.open('%s').at(:title).inner_text # => \"%s\""
        else
          "Page title of %s is „%s“."
        end
      title = Hpricot(open(URI.extract(uri).first)).at(:title).inner_text
      uri = URI.parse(uri).host if uri.size > 40
      h.respond(str % [ uri, title])
    else
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