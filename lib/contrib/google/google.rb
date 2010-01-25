#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

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



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
