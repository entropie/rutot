#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  class Plugins
    include Helper
    include KeywordArguments
  end

  class DefaultPlugins < Plugins
  end
  
  class ChannelPlugins < Plugins
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
