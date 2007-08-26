#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'hpricot'
require 'open-uri'
require 'uri'
require 'net/http'

def tinyurl(uri)
  uri = uri.to_s
  unless uri.empty?
    escaped_uri = URI.escape("http://tinyurl.com/api-create.php?url=#{uri}")
    Net::HTTP.get_response(URI.parse(escaped_uri)).body
  else
    ''
  end
end

def fetch(uri_str, limit = 10)
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0
  uri_str = uri_str.to_s
  response =
    begin
      Net::HTTP.get_response(URI.parse(uri_str))
    rescue
      Net::HTTP.get_response(URI.extract(uri_str).first)
    end
  case response
  when Net::HTTPSuccess     then response

  when Net::HTTPRedirection then fetch(response['location'], limit - 1)
  else
    response.error!
  end
end

respond_on(:PRIVMSG, :uridesc, /https?:\/\//, :args => [:Everything]) do |h|
  begin
    uri = URI.extract(h.raw.join(' ')).select{ |i| begin URI.parse(i); rescue; nil end }.first
    case ct = fetch(uri).content_type
    when /text\/\w+/
      title = Hpricot(open(uri)).at(:title).inner_text
      
      tiny = if uri.size > 60 then "#{tinyurl(uri)}  " else '' end
      uri = URI.parse(uri).host if uri.size > 40
      str = "#{tiny}Page title is: %s.".strip
      h.respond(str % [ title.gsub(/\s+/, ' ').strip ])
    else
    end
  rescue NoMethodError
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
