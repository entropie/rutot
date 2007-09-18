#
# $Id: 88 Michael Trommer <mictro@gmail.com>: message are recorded during ,quiet and saved in ,more$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include :rtv
#require 'rtv'
load 'lib/contrib/rtv/rtv_gem.rb'

module RTV
  class Presenter
    attr_reader :ret
    def puts(*args)
      (@ret ||= []).push(*args)
      @ret.flatten
    end

  end
end

config = {
  :senderfilter => ["pro7", "arte", "3sat", "rtl2", "sat1", "vox", "rtl", "k1"],
  :senderressource => "sendergruppeId:1,3",
  :charset => "UTF-8",
  :senderlimit => 15,
  :eine_pro_sender => false,
  :redundanz => false
}

newconfig =
  begin
    configfile = File.join(Gem.user_home, '.rtv')
    YAML.load(File.read(configfile))
  rescue
    {}
  end

config.update(newconfig)

def rtv_get(arr, cfg)
  swtch = RTV::Switcher.new
  swtch.config = cfg
  
  rtv = RTV::Fetcher.new
  rtv.config = swtch.config
  rtv.options = swtch.uri_options(arr)
  program = rtv.fetch

  prtr = RTV::Presenter.new rtv.config[:charset]
  prtr.config = swtch.config
  prtr.show(program)
  prtr.ret
end

respond_on(:PRIVMSG, :rtv, prefix_or_nick(:rtv), :args => [:Everything]) do |h|
  begin
    h.respond(rtv_get(h.args.flatten, config))
  rescue
  rescue SystemExit 
    h.rescue(ReplyBox.SRY)
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
