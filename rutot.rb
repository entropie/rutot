#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#



Dir.chdir('/home/mit/Source/rutot/')
require "rubygems"
require "pp"


class String
  unless defined?(ord)
    def ord
      self[0]
    end
  end
end

class String; alias :dc :downcase end

def puts(*args)
  print "L"
  args.each_with_index do |arg,i |
    $stdout.print "> ", " "*(i-1).abs, arg
  end
  Kernel.puts
end

require "lib/helper/paramhash"
require "lib/helper/common"
require "lib/responder"
require "lib/plugins"
require "lib/contrib"
require "lib/irc_events"
require "lib/irc"
require "lib/rutot"
require "lib/daemon"
require "lib/config_modules"
require "lib/config"

module Rutot

  
  Version = %w'0 1 7'

  VersionSuffix = 'alpha'
  
  def self.version
    "#{self}-" + Version.join('.') + "-" + VersionSuffix
  end

  def self.start
    unless Daemon.run?
      @daemon = Daemon.start
      @daemon
    else
      raise "daemon already running, #{daemon}}"
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
  
end if __FILE__ == $0



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
