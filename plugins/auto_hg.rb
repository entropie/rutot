#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include :drbinterface

hg = DRBInterface.new


timed_response(10, :auto_hg) do |h|
  if hg.new?
    h.respond(hg.last.last)
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
