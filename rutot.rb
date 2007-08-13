#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "pp"

require "lib/helper/paramhash"
require "lib/daemon"
require "lib/config"

def puts(*args)
  print "L"
  args.each_with_index do |arg,i |
    $stdout.print "> ", " "*(i-1).abs, arg
  end
  Kernel.puts
end
  

module Rutot

  class Rutlov

    attr_accessor :config
    attr_accessor :connections
    
    def initialize(options)
      @config = options[:config_file]
    end

    def start
    end
    
  end

  
  Version = %w'0 0 1'

  VersionSuffix = 'pre-alpha'
  
  def self.version
    "#{self}-" + Version.join('.') + "-" + VersionSuffix
  end

  def self.start
    unless Daemon.run?
      daemon = Daemon.start
      daemon
    end
  end
  
end

begin
  #
  # Rutot starts the friendly Rutlov bot.
  #
  puts "Starting  #{Rutot.version}  at #{Time.now}."
  Kernel.puts
  r = Rutot.start
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
