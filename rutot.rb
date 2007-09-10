#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

Dir.chdir('/home/mit/Source/rutot/')
require "rubygems"
require "text/format"

require "pp"

$KCODE = 'u'

class Array
  def pick_one
    self.sort_by{ rand }.first
  end
end

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

begin
  require "lib/helper/paramhash"
  require "lib/helper/common"
  require "lib/helper/database"
  require "lib/responder"
  require "lib/responder_methods"
  require "lib/plugins"
  require "lib/contrib"
  require "lib/irc_events"
  require "lib/irc"
  require "lib/message_spooler"
  require "lib/rutot"
  require "lib/daemon"
  require "lib/config_modules"
  require "lib/config"
end if __FILE__ == $0

module Rutot

  
  Version = %w'0 3 3'

  VersionSuffix = 'testing'
  
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
  p 1
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
