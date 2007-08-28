#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  module Helper

    module Common

      require 'hpricot'
      require 'open-uri'
      require 'uri'
      require 'net/http'

      Fortunes = [:drugs, :zippy, :futurama, :tao, 'bofh-excuses',
                 :wisdom, :fortunes]
      

      def hlp_fortune(which = [], opts = [:s, :e], only = false)
        w = unless only then Fortunes.dup.push(*which).flatten else which end
        `fortune -#{opts.join(' -')} #{w.join(' ')}`
      end

      
      def hlp_wikipedia(str, lang = 'en')
        str = str.split.map{|a| a.capitalize}.join('_')
        url = "http://#{lang}.wikipedia.org/wiki/#{str}"
        h = Hpricot(open(url))
        "#{url}  " + h.at(:p).inner_text.gsub(/\n/, ' ')
      end

      
      def hlp_google(api = File.open(File.expand_path("~/Data/Secured/google.api")).readlines.join.strip)
        require 'google/api/web'
        Google::API::Web.new(api)
      end


      def hlp_tinyurl(url)
        uri = uri.to_s
        unless uri.empty?
          escaped_uri = URI.escape("http://tinyurl.com/api-create.php?url=#{uri}")
          Net::HTTP.get_response(URI.parse(escaped_uri)).body
        else
          ''
        end
      end


      def hlp_fetch_uri(uri_str, limit = 10)
        raise ArgumentError, 'HTTP redirect too deep' if limit == 0
        uri_str = uri_str.to_s
        response =
          begin
            Net::HTTP.get_response(URI.parse(uri_str))
          rescue
            Net::HTTP.get_response(URI.extract(uri_str).first)
          end
        case response
        when Net::HTTPSuccess     then response
          
        when Net::HTTPRedirection then fetch(response['location'], limit - 1)
        else
          response.error!
        end
      end
      
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
