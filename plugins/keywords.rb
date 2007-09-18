#
# $Id: 124 Michael Trommer <mictro@gmail.com>: mostly plugin base$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

def cl_title(t)
  t.gsub(/<.*>(.*)<.*>/, '\1')
end

respond_on(:PRIVMSG, :kwg, /^#{bot_prefix_regex}\w+\?(?!\s)/) do |h|
  kw = h.raw.join[1..-2]
  if kwn = hlp_fbk(kw)
    h.respond(kwn.to_ary)
  else
    begin
      google = hlp_google
      query = google.search(kw)
      r = query.results.first
      h.respond "[google] \"%s\": %s (approx: %i results)" %
        [cl_title(r.title), r.url, query.result_count]
    rescue
      p $!
    end
  end
end

respond_on(:PRIVMSG, :remove, prefix_or_nick(:remove, :rm, :forget), :args => [:String, :String], :arg_req => true) do |h|
  begin
    kw = hlp_fbk(h.args.first)
    raise "Nothing known about #{h.args.first}" unless kw
    str =
      if h.args.last =~ /^\d+/ and kw.get_at(h.args.last.to_i)
        kw.delete_at(h.args.last.to_i) 
        "Removed entry #{h.args.last} of #{kw.keyword}."
      else
        # FIXME: add backup
        kw.delete
        "Removed #{kw.keyword}"
      end
    h.respond(str)
  rescue
    h.respond(ReplyBox.SRY)
  end
end

respond_on(:PRIVMSG, :kws, /#{bot_prefix_regex}\w+ is (?!also)/) do |h|
  begin
    kw, t, *d = h.raw.join.split
    kw, d = kw[1..-1], d.join(' ')
    raise "exist already" if hlp_fbk(kw)
    if kw.size > 0 and d.size > 0
      kwb = Database::KeywordBundle.create(kw)
      kwb.definitions << ndef = Database::Definition.create(d)
      h.respond(ReplyBox.k)
    end
  rescue
    h.respond(ReplyBox.SRY)
  end
end


respond_on(:PRIVMSG, :kwsa, /#{bot_prefix_regex}\w+ is also/) do |h|
  begin
    kw, t, ot, *d = h.raw.join.split
    kw, d = kw[1..-1], d.join(' ')
    raise "not exist" unless kwb = hlp_fbk(kw)
    kwb.definitions << ndef = Database::Definition.create(d)
    h.respond(ReplyBox.k)
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
