#
# $Id: 92 Michael Trommer <mictro@gmail.com>: plugins/w.rb:  wp lang/argument handling fixed.$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :wp, prefix_or_nick(:wp), :args => [:Everything], :arg_req => true) do |h|
  lang =
    if h.args.join(' ') =~ /^(de|en) /
      h.args.first.shift
      $1
    else
      "en"
    end
  h.respond(hlp_wikipedia(h.args.flatten.join(' '), lang))
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
