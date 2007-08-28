#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

load '/home/mit/iimdb.rb'
require 'google/api/web'
api = File.open(File.expand_path("~/Data/Secured/google.api")).readlines.join.strip
google = Google::API::Web.new(api)


respond_on(:PRIVMSG, :imdb, prefix_or_nick(:imdb), :args => [:Everything], :arg_req => true) do |h|
  query = google.search("site:imdb.com \"" + (a=h.args.join(' ')) + "\"")
  begin
    if query
      r = query.results.first
      imdb = IMDB.new(r.url)
      r = "%s: %s  Rating: %s" % [imdb.title, r.url, imdb.rating]
      r << "\n%s"       % [imdb.extrainfo['plotoutline'].strip]
      r << "\nDirector: %s;  Tagline: %s; Runtime: %s" % [
                                                          imdb.extrainfo['director'],
                                                          imdb.extrainfo['tagline'],
                                                          imdb.extrainfo['runtime']
                                                         ]
      r.gsub!(/\smore/, '')
      h.respond r
    end
  rescue
    h.respond ReplyBox.NO
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
