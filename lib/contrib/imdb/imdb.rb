#
#
# Author:  Unknown
#

class IMDB

  require 'hpricot'
  require 'open-uri'

  def initialize(url)
    @url = url;
    @hp = Hpricot(open(@url))
  end

  def  title
    @title = @hp.at("meta[@name='title']")['content']
  end

  def rating
    rating_text = (@hp/"div.rating/b").inner_text
    if rating_text =~ /([\d\.]+)\/10/
      @rating = $1
    end
    @rating
  end

  def extrainfo
    if @extrainfo == nil #don't do it twice
      @extrainfo = {} #init our hash
      (@hp/"div.info").each do |inf| #go through each info div
        title = inf/"h5" #the type of infobox is stored in h5
        if title.any? #if we found one , we got data
          body = inf.inner_text
          body = body.gsub(/\n/,'') #remove newlines
          if body =~ /\:(.+)/ #extract body from our text
            body = $1
          end
          @extrainfo[title.inner_text.gsub(/[:\s]/,'').downcase] = body #store the body
        end
      end
    end
    @extrainfo
  end

  def reset
    @rating = nil
    @extrainfo = nil
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
