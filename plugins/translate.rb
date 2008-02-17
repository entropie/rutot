#
# $Id: 135 Michael Trommer <mictro@gmail.com>: google uses tinyurl if url is > 60, and translate catches 0$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :translate, prefix_or_nick(:translate, :t, :t8, :tr), :args => [:String, :String, :Everything], :arg_req => true) do |h|
  begin
    trans_prg = "translate -f #{f=h.args.shift.shellescape} -t #{t=h.args.shift.shellescape}"
    trans_string = h.args.shift.gsub("\"", '')
    tstr = `echo "#{trans_string}" | #{trans_prg}`.to_s
    if $?.success?
      h.respond("[Translation #{f}:#{t}]  " + tstr)
    else
      raise "sucks"
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
