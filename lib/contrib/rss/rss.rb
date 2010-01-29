#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require "json"
require "open-uri"
require "pp"
require "simple-rss"

class Rss

  DataFile = "/Users/mit/rutot_rss.json"

  attr_accessor :title
  attr_accessor :link
  attr_accessor :description
  attr_accessor :etag

  attr_accessor :feed_data

  def Rss.current
    @current
  end
  def Rss.current=(obj)
    @current = obj
  end
  
  def Rss.if_updated
    if Rss.current
      newf = Rss.write_json
      Rss.feeds.map{|r| r.name}.each do |feedname|
        if @current[feedname].first["published"].to_s != newf[feedname].first["published"].to_s
          yield [feedname, newf[feedname].first]
        end
      end
    else
      @current = Rss.load
    end
  end
  
  
  def Rss.load
    JSON.parse(File.open(DataFile).read)
  end
  
  def Rss.feeds
    (@feeds ||= [])
  end

  def Rss.inherited(obj)
    feeds << obj
    feeds.uniq!
  end
  
  def initialize
  end

  class << self
    # alias :oldname :name 
    alias :oldname :name 
    def name
      oldname.to_s.split("::").last.downcase
    end
  end
  
  def Rss.fetch_all
    to_save = {}
    feeds.each do |feed|
      to_save[feed.name] = feed.fetch.feed_data
    end
    to_save
  end

  def Rss.watch(int)
    Thread.new do 
      loop do
        Rss.write_json
        sleep int
      end
    end
  end
  
  def Rss.write_json
    puts "writing feedfile #{DataFile}"
    ret = fetch_all
    File.open(DataFile, "w+"){|f| f.write(ret.to_json)}
    ret
  rescue Timeout::Error
    puts :ERR, "error while fetching;  #{$!}"
    Rss.load
  end
  
  def entries
    @entries ||= []
  end
  
  def Rss.fetch
    subfeed = new
    rss = SimpleRSS.parse open(subfeed.url)

    puts "fetching #{subfeed.url}"

    subfeed.title = rss.channel.title.strip
    subfeed.link = rss.channel.link
    subfeed.feed_data = []

    rss.entries.each do |entry|
      contents = {}
      [:title, :author, :dc_date, :link].each do |key|
        contents[key.to_s] = entry.send(key)
      end
      subfeed.feed_data << contents
    end
    subfeed
  end

end



class DevBlog < Rss
  def url
    "http://www.eveonline.com/feed/rdfdevblog.asp"
  end
end

class Eve < Rss
  def url
    "http://www.eveonline.com/feed/rdfnews.asp?tid=1"
  end
end

class Patch < Rss
  def url
    "http://www.eveonline.com/feed/rdfpatchnotes.asp"
  end
end

class XCKD < Rss
  def url
    "http://xkcd.com/rss.xml"
  end
end

class Source < Rss
  def url
    "http://github.com/feeds/entropie/commits/rutot/master"
  end
end

Rss.write_json unless File.exist?(Rss::DataFile)

def feed_to_s(feedname, feed)
  "[%s]: '%s' %s (%s)" % [feedname, feed["title"], hlp_tinyurl(feed["link"]), feed["dc_date"]]
end

Rss.watch(60*5)

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
