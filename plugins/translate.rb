#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :translate, prefix_or_nick(:translate, :t), :args => [:String, :String, :Everything], :arg_req => true) do |h|
  begin
    trans_prg = "translate -f #{f=h.args.shift} -t #{t=h.args.shift}"
    trans_string = h.args.shift.gsub("\"", '')
    h.respond("[Translation #{f}:#{t}]  " + `echo "#{trans_string}" | #{trans_prg}`.to_s)
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
