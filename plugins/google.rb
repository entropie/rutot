#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'google/api/web'
api = File.open(File.expand_path("~/Data/Secured/google.api")).readlines.join.strip
google = Google::API::Web.new(api)

def cl_title(t)
  t.gsub(/<.*>(.*)<.*>/, '\1')
end

respond_on(:PRIVMSG, :google, prefix_or_nick(:google, :search, :g), :args => [:Everything], :arg_req => true) do |h|
  begin
    query = google.search(a=h.args.join(' '))
    r = query.results.first
    h.respond "[google] \"%s\":%s (approx: %i results)" % [cl_title(r.title), r.url, query.result_count]
  rescue
    h.respond "[google] \"%s\" — No Matches" % a
  end
end

respond_on(:PRIVMSG, :gspell, prefix_or_nick(:gspell), :args => [:Everything], :arg_req => true) do |h|
  cp = google.spell(a=h.args.join(' '))
  if cp
    h.respond("[gspell]  %s: %s" % [a, cp])
  else
    h.respond "[gspell]  %s is spelled right." % a
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
