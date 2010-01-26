#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require "json"
require "open-uri"
require "pp"

require "feedzirra"

class Rss

  DataFile = "/Users/mit/rutot_rss.json"

  attr_accessor :title
  attr_accessor :link
  attr_accessor :description
  attr_accessor :etag

  attr_accessor :feed_data

  def self.load(force = false)
    if force or !@data
      @data = JSON.parse(File.open(DataFile).read)
    else
      @data
    end
  end
  
  def self.feeds
    (@feeds ||= [])
  end

  def self.inherited(obj)
    feeds << obj
    feeds.uniq!
  end
  
  def initialize
  end

  class << self
    alias :oldname :name 
    def name
      oldname.to_s.split("::").last.downcase
    end
  end
  
  def self.fetch_all
    to_save = {}
    
    feeds.each do |feed|
      to_save[feed.name] = feed.fetch.feed_data
    end
    to_save
  end

  def self.to_json
    File.open(DataFile, "w+"){|f| f.write(fetch_all.to_json)}
  end
  
  def entries
    @entries ||= []
  end
  
  def self.fetch
    subfeed = new
    rss = Feedzirra::Feed.fetch_and_parse(new.url)

    subfeed.title = rss.title.strip
    subfeed.link = rss.feed_url
    subfeed.etag = rss.etag
    subfeed.feed_data = []
    
    rss.entries.each do |entry|
      contents = {}
      [:title, :author, :published, :url].each do |key|
        contents[key] = entry.send(key)
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

Rss.to_json unless File.exist?(Rss::DataFile)

def feed_to_s(feedname, feed)
  "[%s]: '%s' %s (%s)" % [feedname, feed["title"], hlp_tinyurl(feed["url"]), feed["published"]]
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
