#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

def cl_title(t)
  t.gsub(/<.*>(.*)<.*>/, '\1')
end


respond_on(:PRIVMSG, :kwsearch, prefix_or_nick(:kwsearch, :s, :search), :args => [:Everything]) do |h|
  kw = h.args.flatten.shift
  begin
    if kwn = Database::KeywordBundle.
        find(:sql => "SELECT * FROM #{Database::KeywordBundle.table} WHERE keyword LIKE \"%#{kw}%\"")
      ret = kwn.map{ |k| k.keyword}.join(', ')
      h.respond("You may want to try: %s." % ret)
    end
  rescue
    p $!
    pp $!.backtrace
  end
end


respond_on(:PRIVMSG, :kwd, kwdr=/#{bot.nick}[:, ]+([\w\s_\-]+)\?/) do |h|
  h.raw.to_s =~ kwdr
  kw = $1
  if kwn = hlp_fbk(kw)
    h.respond(kwn.to_ary)
  else
    h.respond(ReplyBox.NO)
  end
end

respond_on(:PRIVMSG, :kwg, kwgr= /#{bot_prefix_regex}([\w\s_\-]+)\?$/) do |h|
  h.raw.to_s =~ kwgr
  kw = $1
  if kwn = hlp_fbk(kw)
    h.respond(kwn.to_ary)
  end
end

respond_on(:PRIVMSG, :remove, prefix_or_nick(:remove, :rm, :forget), :args => [:Everything], :arg_req => true) do |h|
  begin
    args = h.args.flatten
    args = (if args.last =~ /^\d+$/ then args[0..-2] else args end)
    kw = hlp_fbk(args.join(' '))
    raise "Nothing known about #{h.args.first}" unless kw
    str =
      if h.args.last.last =~ /^\d+/ and kw.get_at(i=h.args.last.last.to_i)
        kw.delete_at(i) 
        "Removed entry #{i} of #{kw.keyword}."
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

respond_on(:PRIVMSG, :kws, kwsr=/^#{bot_prefix_regex}(\w[\w\s_\-]+) is (?!also)(.*)$/) do |h|
  begin
    h.raw.to_s =~ kwsr
    kw, d = $1, $2
    raise "exist already" if hlp_fbk(kw)
    if kw.size > 0 and d.size > 0
      kwb = Database::KeywordBundle.create(kw.strip)
      kwb.definitions << ndef = Database::Definition.create(d.strip)
      h.respond(ReplyBox.k)
    end
  rescue
    h.respond(ReplyBox.SRY)
  end
end


respond_on(:PRIVMSG, :kwsa, kwsar=/#{bot_prefix_regex}([\w\s_\-]+) is also(.*)$/) do |h|
  begin
    h.raw.to_s =~ kwsar
    kw, d = $1, $2
    raise "not exist" unless kwb = hlp_fbk(kw)
    kwb.definitions << ndef = Database::Definition.create(d.strip)
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
