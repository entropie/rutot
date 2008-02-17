#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :ignore, prefix_or_nick(:ignore), :args => [:String]) do |h|
  begin
    sender = h.msg.prefix.split('!').first
    raise "deine mama" unless h.bot.channels.first.whitelist.include?(sender)
    raise if a = h.args.to_s and a.empty?
    kwb = unless hk = hlp_fbk('ignorelist')
            Database::KeywordBundle.create('ignorelist')
          else
            hk
          end
    kwb.definitions << ndef = Database::Definition.create(a)
    h.respond("ignoring #{a}")
  rescue
    h.respond ReplyBox.SRY
  end
end

respond_on(:PRIVMSG, :ignorel, prefix_or_nick(:ignorelist)) do |h|
  if kwn = hlp_fbk('ignorelist')
    h.respond(kwn.to_ary)
  end
end

respond_on(:PRIVMSG, :rmignore, prefix_or_nick(:rmignore), :args => [:Everything], :arg_req => true) do |h|
  begin
    sender = h.msg.prefix.split('!').first
    raise "deine mama" unless h.bot.channels.first.whitelist.include?(sender)
    raise if a = h.args.to_s and a.empty?
    args = h.args.flatten
    kw = hlp_fbk('ignorelist')
    raise "Nothing known about #{h.args.first}" unless kw
    if h.args.last.last =~ /^\d+/ and kw.get_at(i=h.args.last.last.to_i)
      kw.delete_at(i) 
      h.respond( "Removed entry #{i} of #{kw.keyword}." )
    else
      raise "unknown #{args.to_s}"
    end
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
