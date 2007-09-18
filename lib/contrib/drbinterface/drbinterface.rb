#
# $Id: 126 Michael Trommer <mictro@gmail.com>: fix-line-spaces$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'drb'

class DRBInterface

  Host = 'localhost'
  Port = 7666

  attr_reader :new

  def new?
    @@new
  end

  def initialize
    begin
      Thread.new {
        begin
          @@drb ||= DRb.start_service("druby://#{Host}:#{Port}", self)
          @@drb.thread.join
        rescue
        end
      }
    rescue
    end
    @@new = false
    @@messages ||= { }
  end

  def last
    @@new = false
    @@messages.sort_by{ |t, m|
      t
    }.last
  end

  def empty?
    @@messages.empty?
  end

  def message(msg)
    @@new = true
    @@messages[Time.now] = msg
  end
end

# hg = HGWatch.restart.new
# hg.message('foo bar batz')
# p hg.last
=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
