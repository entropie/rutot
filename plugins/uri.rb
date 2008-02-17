#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :uridesc, /https?:\/\//, :args => [:Everything]) do |h|
  begin
    uri = URI.extract(h.raw.join(' ')).select{ |i| begin URI.parse(i); rescue; nil end }.first
    case ct = hlp_fetch_uri(uri).content_type
    when /text\/\w+/
      title = Hpricot(open(uri)).at(:title).inner_text.to_s[0..200]
      
      tiny = if uri.size > 60 then "#{hlp_tinyurl(uri)}  " else '' end
      str = "#{tiny}Page title is: %s.".strip
      h.respond(str % [ title.gsub(/\s+/, ' ').strip ])
    else
      h.respond hlp_tinyurl(uri) if uri.size > 60
    end
  rescue Hpricot::ParseError
    p $!
  rescue NoMethodError
    p $!
  rescue Timeout::Error
    #h.respond("timeout")
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
