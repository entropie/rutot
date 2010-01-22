#
# $Id: 135 Michael Trommer <mictro@gmail.com>: google uses tinyurl if url is > 60, and translate catches 0$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "cgi"
require "open-uri"
require "json"
require "pp"



#google = hlp_google

def google_search(str)
  string = CGI.escape(str)
  url = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{string}"

  res = JSON.parse(open(url).read)["responseData"]["results"].first
  url, title, text = res["unescapedUrl"], res["title"], res["content"]
  strip_tags = proc{|s| s.gsub(/<\/?[^>]*>/, "")}
  [url, strip_tags.call(title), strip_tags.call(text)]
end

def cl_title(t)
  t.gsub(/<.*>(.*)<.*>/, '\1')
end



respond_on(:PRIVMSG, :google, prefix_or_nick(:google, :g), :args => [:Everything], :arg_req => true) do |h|
  begin
    #query = google.search(a=h.args.join(' '))
    r = google_search(a=h.args.join(' '))
    nu = if r.first.to_s.size > 60 then hlp_tinyurl(r.first) else r.first end
    h.respond "[G] \"%s\": %s - %s" % [a, r.first, r[1]]
  rescue
    p $!
    h.respond "[G] \"%s\" — No Matches" % a
  end
end

respond_on(:PRIVMSG, :gspell, prefix_or_nick(:gspell), :args => [:Everything], :arg_req => true) do |h|
  cp = google.spell(a=h.args.join(' '))
  if cp
    h.respond("[GS]  %s: %s" % [a, cp])
  else
    h.respond "[GS]  %s is spelled right." % a
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
