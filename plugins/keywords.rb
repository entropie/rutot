#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


def fbk(kw)
  Database::KeywordBundle.find_by_keyword(kw)
end

respond_on(:PRIVMSG, :kwg, /,\w+\?/) do |h|
  kw = h.raw.join[1..-2]
  if kw = fbk(kw)
    h.respond(kw.to_ary)
  else
    h.respond('google?')
  end
end

respond_on(:PRIVMSG, :remove, prefix_or_nick(:remove, :rm, :forget), :args => [:String, :String], :arg_req => true) do |h|
  begin
    kw = fbk(h.args.first)
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

respond_on(:PRIVMSG, :kws, /#{bot_prefix}\w+ is [^(also)]/) do |h|
  begin
    kw, t, *d = h.raw.join.split
    kw, d = kw[1..-1], d.join(' ')
    raise "exist already" if fbk(kw)
    if kw.size > 0 and d.size > 0
      kwb = Database::KeywordBundle.new(kw)
      kwb.save
      kwb.definitions << ndef = Database::Definition.new(d)
      ndef.save
      h.respond(ReplyBox.k)
    end
  rescue
    h.respond(ReplyBox.SRY)
  end
end


respond_on(:PRIVMSG, :kwsa, /#{bot_prefix}\w+ is also/) do |h|
  begin
    kw, t, ot, *d = h.raw.join.split
    kw, d = kw[1..-1], d.join(' ')
    raise "not exist" unless kwb = fbk(kw)
    kwb.definitions << ndef = Database::Definition.new(d)
    ndef.save
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