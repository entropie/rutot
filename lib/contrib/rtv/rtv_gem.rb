#
# $Id: 132 Michael Trommer <mictro@gmail.com>: source cleaned$
# Author:  Robert Retzbach <rretzbach@gmail.com>
# Author:  Christian Neukirchen <chneukirchen@gmail.com>
#

require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'cgi'
require 'iconv'
require 'time'
require 'base64'

$KCODE = 'u'

Channel = %w{ard zdf rtl sat1 pro7 k1 rtl2 super vox arte tele5 3sat dvier br hr mdr n3 rbb swr wdr bralp tvb h1 orf1 orf2 atv sf1 sf2 prs dwtv extra fes mux ztk zdoku zinfo dsf euro mtv viva nick kika qvc tw1 teno cc bbc cnn euron n24 ntv blm dmax nl1 nl2 nl3 pspo1 dir1 gold heima aplan butv disco junio mgm plane scifi 13th hit24 disge foge blum blume arena axn kinow sat1c silve histo nasn toon pr1 pr2 pr3 pr4 disne prfc prff prn prser krimi}

module RTV
  class Program
    attr_reader :channel

    def initialize
      @channel = {}
    end
    def << show
      @channel[show.channel] ||= []
      @channel[show.channel] << show
    end
  end
  class Show
    attr_accessor :channel, :name, :time, :date, :desc, :showview, :options

    Filler = "\t"

    def to_s *lastshow
      if @options[:redundanz]
        self.to_a.compact.join(Filler)
      else
        lastshow = if lastshow.first.nil?
                     [()] * to_a.size
                   else
                     lastshow.first
                   end
        self.to_a.zip(lastshow.to_a).map{|x,y| (x == y) ? (' ' * x.to_s.size) : x}.reject{|x| x.empty?}.join(Filler)
      end
    end

    def to_a
      tmp = [@channel, @date, @time, @name]
      tmp << @desc if @options[:desc]
      tmp
    end
  end
  class Fetcher
    attr_accessor :options, :config

    def initialize
      @options = {}
      @shows = Program.new
    end

    def fetch
      while search_results?(doc = get_hdoc)
        extract_shows doc
        @options[:offset] += 1
        print "." if $DEBUG
      end
      puts if $DEBUG
      return @shows
    end

    def extract_shows doc
      if @options[:format] == 'search'
        daten = (doc/"div[@id='titel-uebersicht']")
        daten.each do |datum|
          zeiten = datum.parent.parent.parent.next_sibling
          unless zeiten.nil?
            zeiten = zeiten.search("span.tv-sendung-uhrzeit")
          else
            puts "Keine Suchergebnisse!" if $DEBUG
          end
          zeiten.each do |zeit|
            show = Show.new
	    show.options = @config
            show.time = zeit.innerText
	    show.desc, show.showview = time_to_desc_and_showview(zeit)
            show.name = time_to_name(zeit)
            show.channel = time_to_channel(zeit)
            show.date = datum.innerText[/^\D*(.+) Suchergebnis/, 1]
            add_show show
          end
        end
      else
        zeiten = (doc/"span.tv-sendung-uhrzeit")
        zeiten.each do |zeit|
          show = Show.new
          show.options = @config
          show.time = zeit.innerText
          show.desc, show.showview = time_to_desc_and_showview(zeit)
          show.name = time_to_name(zeit)
          show.channel = time_to_channel(zeit)
          add_show show
        end
      end
    end

    private
    def add_show show
      @shows << show
    end

    def get_hdoc
      begin
        uri = convert_to_url("http://www.klack.de/") + '?' + hsh_to_rqst(@options)
        puts "URL: #{uri}" if $DEBUG
        doc = Hpricot(open(uri))
      rescue
        puts "No Network Connection!"
      end
    end

    def search_results? doc
      (doc/"td.noresult").empty?
    end

    def hsh_to_rqst hsh
      hsh.to_a.map{|x| x.map{|y| CGI.escape(y.to_s)}.join('=')}.join('&')
    end

    def time_to_name zeit
      zeit.parent.next_sibling.next_sibling.at("a.tv-sendung-titel").innerText
    end

    def time_to_channel zeit
      zeit.parent.parent.at("span.tv-sendung-info/a").attributes["href"][/channelId=([^&]+)/, 1].downcase
    end

    def time_to_desc_and_showview zeit
      desc_showv = zeit.parent.parent.at("span.tv-sendung-info").innerText.strip.gsub(/[\t\r\n]+/, "\t")
      desc = desc_showv.sub(/^\([^()]+\)\s+/, '').sub(/\s+Showview [0-9-]+/, '')
      showview = desc_showv[/\s+Showview ([0-9-]+)/, 1]
      [desc, showview]
    end

    def convert_to_url str
      # entferne alle störenden Buchstaben und erstelle die URL
      url = Base64.decode64("aHR0cDovL3d3dy50dnRvZGF5LmRlL3Byb2dyYW0yMDA3")
    end
  end

  class Presenter
    Source_charset = 'ISO-8859-1'

    attr_accessor :config

    def initialize charset = 'UTF-8'
      @target_charset = charset
    end

    def show program
      senderlimit = @config[:senderlimit]
      @config[:senderfilter].each do |channel|
        lastshow = nil
        tmp = program.channel[channel]

        unless tmp.nil?
          tmp.each do  |show|
            return if (@config[:senderlimit] -= 1) < 1

            puts Iconv.iconv(@target_charset, Source_charset, show.to_s(lastshow))

            break if @config[:eine_pro_sender]
	    lastshow = show
          end
        end
      end
    end
  end

  class Switcher
    attr_accessor :config

    Usage = 'RTV - a command line ruby tv guide

USAGE

        tv [ELEMENT] ...

        ELEMENT kann folgende Werte enthalten:

        TIME            Sendezeit im Format HH oder HH:MM (maximal eine TIME sinnvoll)
        DATE            Datum im Format DD.MM
        CHANNEL         Sender aus der Liste in doc/senderliste.txt
        PATTERN         Suchbegriff (darf kein Sendername sein, siehe b))
        KEY:VALUE       Schlüssel und Wert für Konfigurationsoptionen
        DESCRIPTION     Beschreibung, feste Zeichenkette "-d"
        HELP            Hilfe, feste Zeichenkette "help" (gibt diese Seite aus)


EXAMPLES

        tv                      Aktuelle Sendungen für ausgewählte Sender
        tv 20                   Heute 20 Uhr alle Sendungen für ausgewählte Sender
        tv 24.12.               Alle Sendungen an Heilig Abend für ausgewählte Sender
        tv pro7 sat1            Aktuelle Sendungen von nur Pro7 und Sat.1
        tv simpsons             Alle Sendungen über Die Simpsons für alle Sender
        tv redundanz:true       Zeigt alle Infos an. (Nützlich für grep)
        tv -d                   Aktuelle Sendungen für ausgewählte Sender mit Beschreibung
        tv help                 Gibt diese Seite aus

        Beliebige sinnvolle Kombinationen in beliebiger Reihenfolge sind möglich:
        tv pro7 -d 20 11.07. sat1 - Alle Sendungen auf Pro7 und Sat.1 um 20 Uhr am 11.07. mit Beschreibung'

    def initialize
      @uri_options = {}
    end

    def uri_options args
      set_defaults

      tmp_channel = @config[:senderfilter]
      @config[:senderfilter] = []

      args.each do |arg|
        case arg.downcase

          # Konfigurationenmodus
        when /(\w+):(\w+)/
          @config.update YAML.load("--- :" + $1 + ": " + $2)

          # Hilfemodus
        when "help"
          puts Usage

          # Beschreibungmodus
        when "-d"
          @config[:desc] = true

          # Datummodus
        when /^\d{1,2}\.\d{1,2}\.$/
          @uri_options[:date] = arg + Time.now.year.to_s

          # Stundenmodus
        when /^\d{1,2}(?:\d{2})?$/
          @uri_options[:time] = arg

          # Channelname oder -alias
        when *Channel
          @config[:senderfilter] << arg.downcase

          # Suchmodus
        else
          @uri_options.update({:search => arg, :format => 'search', :time => 'all', :date => 'all', :slotIndex => 'all'})
          @config[:senderfilter] = Channel
        end
      end

      # when channels are specified, use them only
      @config[:senderfilter] = tmp_channel if @config[:senderfilter].empty?

      @uri_options
    end

    private
    def set_defaults
      # Haupt- und Regionalsender
      @uri_options = {:date => 'now', :time => 'now', :format => 'genre', :channel => @config[:senderressource], :order => 'time', :offset => 0}
    end
  end
end

