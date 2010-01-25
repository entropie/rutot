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

module EveHelper

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

  def get_item_from_name(name, short = true, like = false)
    qry =
      unless like
        "select * from invTypes where UPPER(typeName) = UPPER('#{name.to_s.strip}')"
      else
        "select * from invTypes where typeName like '%#{name.to_s.strip}%'"
      end
    result = DB.execute(qry)
    if result.empty?
      return get_item_from_name(name, short, !like)
    else
      result.map do |item|
        if short
          [item[0].to_i, item[2]]
        else
          item
        end
      end
    end
  end

  def reject_non_market_item(items, &blk)
    ret = items.reject{|i|
      i[13].nil?
    }
    ret.each(&blk) if block_given?
    ret
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
end

class EveCentral

  BASE_URL = EVE_CENTRAL_BASE_URL

  DEFAULT_PARAMS = {:sethours => 24}

  TIMEOUT = 5
  
  attr_accessor :url
  attr_accessor :default_params

  def url
    @url || BASE_URL
  end
  
  def default_params
    @default_params || DEFAULT_PARAMS
  end

  def mk_url(params)
    url + "?" + default_params.
      merge(params).map{|h,k| "#{h.to_s.downcase}=#{CGI.escape(k.to_s)}"}.join("&")
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

class EveCentralQuick < EveCentral

  extend EveHelper
  
  BASE_URL = "http://eve-central.com/api/quicklook"
  def url
    @url || BASE_URL
  end
  
  def default_params
    @default_params || DEFAULT_PARAMS
  end

  def parse_market_data(params)
    url = mk_url(params)
    data, fields = {}, [:sell, :buy]

    #xml = Hpricot.XML(open("/Users/mit/test1.xml"))
    xml = Hpricot.XML(open(url))

    all_orders = {}
    
    fields.map{|fn| [fn, "#{fn}_orders"]}.each do |fn, field|
      t = all_orders[fn] ||= {}
      xml.search("#{field}/order").each do |order|
        next if order.name.strip.empty?
        st = t[order.attributes["id"].to_i] ||= OpenStruct.new
        order.search("/*").each do |entry|
          next if entry.name.strip.empty?
          st.send("#{entry.name}=".to_sym, entry.inner_text)
        end
      end
    end
    all_orders
  end

  def self.get_min_max(id, system)
    id = id.to_i
    ss = get_solarSystem_id_via_name(system)
    ret = []
    data = ECQ.get_market_data(:typeID => id, :usesystem => ss)
    get_min_max = proc{|prices| [prices.min, prices.max]}

    ret = [:sell, :buy].map{|what|
      get_min_max.call(data[what].values.map{|d| d.price.to_f})
    }
    {:item_name => get_item_from_id(id)[2], :solar_system_name => system, :sell => ret.first, :buy => ret.last}
  end

end

EC = EveCentral.new
ECQ = EveCentralQuick.new

include EveHelper

if $0 == __FILE__

  items = reject_non_market_item(get_item_from_name(item="10mn afterburner II", false))
  p EveCentralQuick.get_min_max(items.first[0], "Jita")

  exit
  
  items = reject_non_market_item(get_item_from_name(item="1mn afterburner II", false))
  msg = []
  if items.size > 10
    msg << "More than 5 results yielded, please rephrase your input '#{item}'"
  elsif items.size == 1
    msg << "One Result for #{item}"
    msg << ECQ.get_market_data(:typeID => 438, :usesystem => ss)
  elsif items.size == 0
    msg << "No Result for #{item}"
  else
    msg << "Results for '#{item}', please specify\n"
    msg << items.map{|i| i[2] }.join(", ")
  end

  puts msg.join("\n")
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
