#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require 'reve'
require "pp"
require "sqlite3"
require "hpricot"
require "open-uri"
require "ostruct"
require "timeout"


DB = SQLite3::Database.new("/Users/mit/dom103-sqlite3-eam-v1")

EVE_CENTRAL_BASE_URL = "http://api.eve-central.com/api/marketstat"

# provides UID, APIK and CID
if File.exist?(file="/Users/mit/.eve_api.rb")
  require file
else
  require File.expand_path("~/.eve_api.rb")
end

API = Reve::API.new(UID, APIK)

def get_solarSystem_name_via_id(sysid)
  DB.execute("select solarSystemName from mapSolarSystems where solarSystemID = ?", sysid.to_i).flatten.first
end

def get_solarSystem_id_via_name(name)
  DB.execute("select solarSystemID from mapSolarSystems where solarSystemName = ?", name).flatten.first.to_i
end

def get_mapkills_from_solarSystem(name)
  ss = get_solarSystem_id_via_name(name)
  if ss != 0
    API.map_kills.select{|m| m.system_id == ss}.first
  end
end

def get_item_from_id(id)
  DB.execute("select * from invTypes where typeID = ?", id.to_i).flatten
end

def get_item_from_name(name, short = true)
  DB.execute("select * from invTypes where typeName = ?", name.to_s.strip).map{|item|
    if short
      [item[0].to_i, item[2]]
    else
      item
    end
  }
end

def starbase_details(target_system = nil)
  ret = []
  API.starbases(:characterid => CID).each do |sb|
    system = get_solarSystem_name_via_id(sb.system_id)

    next if not target_system.nil? and not target_system.empty? and system != target_system
    
    desc =  "%s (%s)" % [system,get_item_from_id(sb.type_id)[2]]
    stra = []
    API.starbase_fuel(:characterid => CID, :itemid => sb.item_id).each do |fi|
      item = get_item_from_id(fi.type_id)
      stra << "%-s %i" % ["#{item[2]}:", fi.quantity]
    end
    ret << "%s: %s" % [desc,stra.join(", ")]
  end
  ret
end


class EveCentral

  BASE_URL = EVE_CENTRAL_BASE_URL

  DEFAULT_PARAMS = {:hours => 24}

  TIMEOUT = 5
  
  attr_accessor :url
  
  def url
    @url || BASE_URL
  end
  
  def mk_url(params)
    url + "?" + DEFAULT_PARAMS.merge(params).map{|h,k| "#{h.to_s.downcase}=#{CGI.escape(k.to_s)}"}.join("&")
  end
  
  def initialize
  end

  def get_market_data(params)
    Timeout::timeout(5) do
      parse_market_data(params)
    end
  end

  def parse_market_data(params)
    url = mk_url(params)
    data, fields = {}, [:all, :sell, :buy]

    xml = Hpricot.XML(open(url))
    
    fields.each do |field|
      xml.search("#{field}/*").each do |ele|
        next if ele.name.strip.empty?
        data[field] ||= OpenStruct.new
        data[field].send("#{ele.name}=".to_sym, ele.inner_text)
      end
    end
    data
  end
  
end
EC = EveCentral.new


if $0 == __FILE__
  get_item_from_name("Armageddon").each do |item|
    itemID, itemName = item
    p EC.get_market_data(:typeID => itemID)[:all]
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
