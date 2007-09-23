#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'net/http'
require 'uri'

class Rafb
  LANG = %w{C89 C C++ Java Pascal Perl PHP PL/I Python Ruby Scheme SQL VB XML Plain Text}
  TABS = %w{No 2 3 4 5 6 8}
  RAFB, RURL = %w{http://rafb.net/paste/paste.php
                 http://rubyurl.com/rubyurl/create}.map { |u| URI.parse(u) }

  attr_reader :bnick, :desc, :str
  attr_accessor :rurlmode

  def initialize(bnick, desc, str)
    @bnick, @desc, @str = bnick, desc, str
  end
  
  def paste
    form = {
      'lang' => (@rurlmode || 'Ruby'),
      'nick' => @bnick,
      'desc' => @desc,
      'cvt_tabs' => 'No',
      'text' => @str}

    form['lang'] = LANG.detect {|l| l.casecmp(form['lang']) == 0} or
      raise "Unrecognized language (allowed values are #{LANG.inspect})" 
    form['cvt_tabs'] = TABS.detect {|l| l.casecmp(form['cvt_tabs']) == 0} or
      raise "Unrecognized tab length (allowed values are #{TABS.inspect})" 
    if(nres = Net::HTTP.post_form(RAFB, form)).is_a?(Net::HTTPRedirection)
      return nres['location']
    else
      return nres.body
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
