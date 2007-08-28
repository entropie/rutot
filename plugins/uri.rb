#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :uridesc, /https?:\/\//, :args => [:Everything]) do |h|
  begin
    uri = URI.extract(h.raw.join(' ')).select{ |i| begin URI.parse(i); rescue; nil end }.first
    case ct = hlp_fetch_uri(uri).content_type
    when /text\/\w+/
      title = Hpricot(open(uri)).at(:title).inner_text
      
      tiny = if uri.size > 60 then "#{hlp_tinyurl(uri)}  " else '' end
      uri = URI.parse(uri).host if uri.size > 40
      str = "#{tiny}Page title is: %s.".strip
      h.respond(str % [ title.gsub(/\s+/, ' ').strip ])
    else
      h.respond hlp_tinyurl(uri)
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
