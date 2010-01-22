#!/usr/bin/env ruby
#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


PWD = File.expand_path(File.dirname(__FILE__))
Dir.chdir(File.expand_path('~/Source/rutot.git/'))

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

class NilClass; def to_irc_msg; "nil"; end; end

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
  require "lib/helper/shellwords"  
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

  
  Version = %w'0 3 7'

  VersionSuffix = 'testing'
  
  def self.version
    "#{self}-" + Version.join('.') + (if VersionSuffix.nil? then '' else ("-" + VersionSuffix) end)
  end

  def self.start(config = nil)
    unless Daemon.run?
      @daemon = Daemon.start(config)
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
  cfg = if ARGV.empty? then nil else ARGV.first end
  r = Rutot.start(:config_file => cfg)
end if __FILE__ == $0



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
