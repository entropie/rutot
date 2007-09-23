#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :anc, prefix_or_nick(:anc), :args => [:String, :Everything], :arg_req => true) do |h|
  anstr = 'an -n 10 -d /usr/share/dict/words -c %s %s'
  ret =`#{ anstr % [h.args.first, h.args.last.gsub(/\s+/,'')] }`
  begin
    if ret =~ /^an: /
      raise "\"#{ret.chomp}\""
    else
      h.respond "Anagrams: " + ret.split("\n").map{|r| r.strip}.join(', ')
    end
  rescue
    h.respond ReplyBox.SRY
  end  
end

respond_on(:PRIVMSG, :anagram, prefix_or_nick(:an), :args => [:Everything], :arg_req => true) do |h|
  anstr = 'an -n 10 -d /usr/share/dict/words %s'
  ret =`#{ anstr % [h.args.last.to_s.gsub(/\s+/,'')] }`
  begin
    if ret =~ /^an: /
      raise "\"#{ret.chomp}\""
    else
      h.respond "Anagrams: " + ret.split("\n").map{|r| r.strip}.join(', ')
    end
  rescue
    h.respond ReplyBox.SRY
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
