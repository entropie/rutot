#
# $Id: 124 Michael Trommer <mictro@gmail.com>: mostly plugin base$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

google = hlp_google

def cl_title(t)
  t.gsub(/<.*>(.*)<.*>/, '\1')
end

respond_on(:PRIVMSG, :google, prefix_or_nick(:google, :search, :g), :args => [:Everything], :arg_req => true) do |h|
  begin
    query = google.search(a=h.args.join(' '))
    r = query.results.first
    h.respond "[G] \"%s\": %s (approx: %i results)" % [cl_title(r.title), r.url, query.result_count]
  rescue
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
