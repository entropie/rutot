#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "lib/helper/paramhash"
require "lib/daemon"
require "lib/config"

def puts(*args)
  args.each_with_index do |arg,i |
    $stdout.print " > ", "  "*i, arg
  end
  Kernel.puts
end
  

module Rutot

  class Rutlov

    attr_accessor :config
    
    def initialize(options)
      @config = options[:config_file]
    end

    def start
      self
    end
    
  end

  
  Version = %w'0 0 1'
  VersionSuffix = 'pre-alpha'
  
  def self.version
    Version.join('.') + "-" + VersionSuffix
  end

  def self.start
    unless Daemon.run?
      Daemon.start
    end
  end
  
end


# Rutot starts the friendly Rutlov bot.
Rutot.start


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
