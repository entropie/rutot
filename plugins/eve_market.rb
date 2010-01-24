#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "/Users/mit/eve.rb"

# http://www.misuse.org/science/2008/03/27/converting-numbers-or-currency-to-comma-delimited-format-with-ruby-regex/
def comma_numbers(number, delimiter = ',')
  number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1#{delimiter}").reverse
end

respond_on(:PRIVMSG, :pc, prefix_or_nick(:pc, :pricecheck), :args => [:String, :Everything]) do |h|
  what = h.args.first
  unless ["all", "sell", "buy"].include?(what)
    item = "#{what} #{h.args.last}"
    what = :all
  else
    what, *item = h.args
  end

  item = item.to_s.strip
  
  begin
    what = what.to_sym||:all
    ret = []
    get_item_from_name(item.to_s).each do |sitem|
      itemID, itemName = sitem
      
      EC.get_market_data(:typeID => itemID)[what].to_a.each do |k|
        vals = [k.min, k.max, k.avg, k.volume, k.stddev, k.median].map{|v| comma_numbers(v.to_f)}
        ret << "#{item} (#{what}): Min: %s; Max: %s; Avg: %s; Volume: %s; Stddev: %s; Median: %s" % vals
      end
    end
    h.respond(ret)
  rescue Timeout::Error
    h.respond("Request timed out.")
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
