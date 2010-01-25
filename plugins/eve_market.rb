#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include :eve

# http://www.misuse.org/science/2008/03/27/converting-numbers-or-currency-to-comma-delimited-format-with-ruby-regex/
def comma_numbers(number, delimiter = ',')
  number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1#{delimiter}").reverse
end

def market_data_to_s(id, what)
  ret = ''
  EC.get_market_data(:typeID => id)[what].to_a.each do |k|
    vals = [k.min, k.max, k.avg, k.volume, k.stddev, k.median].map{|v| comma_numbers(v.to_f)}
    ret << "#{k.first} (#{what}): Min: %s; Max: %s; Avg: %s; Volume: %s; Stddev: %s; Median: %s" % vals
  end
  ret
end

respond_on(:PRIVMSG, :pc, prefix_or_nick(:pc, :pricecheck), :args => [:String, :Everything]) do |h|
  what = h.args.first
  unless ["all", "sell", "buy", '*'].include?(what)
    item = "#{what} #{h.args.last}"
    what = :all
  else
    what, *item = h.args
  end

  item = item.to_s.strip
  begin
    what = what.to_sym||:all

    items = reject_non_market_item(get_item_from_name(item, false))
    msg = []
    if items.size > 10
      msg << "More than 10 results yielded, please rephrase your input '#{item}'"
      msg << items[0..10].map{|i| i[2] }.join(", ") + " ..."
    elsif items.size == 1
      msg << "One Result for #{items.first[2]}"
      msg << market_data_to_s(items.first[0].to_i, what)
    elsif items.size == 0
      msg << "No Result for #{item}"
    else
      msg << "Resultlist for '#{item}', please specify\n"
      msg << items.map{|i| i[2] }.join(", ")
    end
    h.respond(msg)
  rescue Timeout::Error
    h.respond("Request timed out. (#{$!})")
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
