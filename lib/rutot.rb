#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  class Rutlov

    # Config releated only to current bot instance.
    attr_accessor :config

    # server connections
    attr_accessor :connections
    
    def initialize(options)
      @config = options[:config_file]
    end

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
