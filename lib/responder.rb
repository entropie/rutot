#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class String
  def to_irc_msg
    split("\n").reject{|r| r.strip.empty? }
  end
end

module Rutot

  class Plugins
   
    PluginDirectory = File.join(File.dirname(__FILE__), '..', 'plugins')

    attr_reader :responder
    attr_reader :bot

    attr_reader :independent
    
    def initialize(bot)
      @bot, @independent = bot, Independent.new(bot)
      reset
    end

    def load_plugin_files!
      bot.channels.inject([]) { |m, chan|
        m.push(*chan.plugins)
        m.push(*chan.independent)
      }.uniq.each do |mod|
        select(mod)
      end
    end
    
    def reset
      if @responder
        detach(@bot.conn, @bot)
        @responder.clear
      end
      @independent = Independent.new(bot)
      @responder = Responder.new(bot)
    end

    def reload
      reset
      load_plugin_files!
      attach(@bot.conn, @bot)
    end


    def handle_independent_things!
      self.independent.each do |ind|
        tchan = bot.config.channels.
          select{ |c| c.independent.include?(ind.name)}
        tchan.each do |c|
          begin
            if ind.last[c.name] + ind.interval <= Time.now
              bot.spooler.push(c.name, parse_plugin_retval(ind.call))
              ind.last[c.name] = Time.now
            else
              # nothing
            end
          rescue
            p $!
            ind.last[c.name] = Time.now
          end
        end
        sleep 1
      end
    end
    
    
    def attach(con, bot)
      bot.channels.each do |chan|
        self.responder.each do |plugin|
          
          puts :PLG, "#{bot.nick}:@#{chan.name} ATTACHING plugin: `#{plugin.name}´"
          con.add_event(plugin.type, plugin.name) do |msg, con|
            message = msg.params.last
            target = msg.params.first

            plugin.channel = msg.params.first
            plugin.msg = msg
            plugin.con = con
            
            tchan = bot.config.channels[plugin.channel]

            if(plugin && tchan && tchan.plugins.include?(plugin.name))
              if plugin.keywords.any?{ |a| message =~ a }
                puts :PLG, "#{message} matches #{plugin.name}"
                ret = parse_plugin_retval(plugin.call(message))
                bot.spooler.push(target, *ret)
              end
            elsif plugin.keywords.any?{ |a| message =~ a }
              puts :PLG, "#{message} matches #{plugin.name}"
              ret = parse_plugin_retval(plugin.call(message))
              bot.spooler.push(target, *ret)
            end
          end
        end
      end
    end


    def parse_plugin_retval(pret)
      pret.to_s.to_irc_msg
    end
    private :parse_plugin_retval
    

    def detach(con, bot)
      load_plugin_files!
      self.responder.each do |plugin|
        puts :PLG, "#{bot.nick}: DETACHING plugin: `#{plugin.name}´"
        con.remove_event(plugin.type, plugin.name)
      end
    end
    

    def respond_on(type, name, handler, options = { }, &blk)
      options.extend(ParamHash).
        process!(:args => :optional, :arg_req => :optional)
      @responder.add(type, handler, options, &blk).name = name
    end


    def timed_response(intervall, name, options = { }, &blk)
      # @responder.add(:NULL, nil, options, &blk).name = "timed_#{name}"
      @independent.add_timed(intervall, name, options, &blk)
    end

    def bot_prefix
      bot.config.prefix
    end

    def prefix(arg, h = 1)
      @prefix ||= Events::EventPrefix
      /#{if h == 1 then "^" else "" end}#{@prefix*h} ?(#{arg.to_s})(?:$|\s+)/
    end


    def prefix_or_nick(*args)
      args.inject([]) do |m, arg|
        rrgx = "^#{bot.nick}[:, ]+"
        rrgx += "(#{arg})(?:$|\s+)"
        m << [prefix(arg), prefix(arg, 2), Regexp.new(rrgx)]
      end.flatten
    end


    def prefix_or_nick_r(rgx, arg)
      rrgx = "^#{bot.nick}[:, ]+"
      rrgx += "(#{rgx})(?:$|\s+)"
      [Regexp.new(rrgx)]
    end


    def select(name)
      Dir["#{PluginDirectory}/*.rb"].#
        grep(/#{name}\.rb$/).each { |pluginfile|
        puts :PLG, "loading #{pluginfile}"
        self.load(pluginfile)
      }
    end
    

    def load(plugin)
      b = self.dup
      b.extend(Helper)
      b.extend(Helper::Common)
      b.extend(Helper::Database)
      bind = b.send(:binding)
      eval(File.open(plugin).readlines.join, bind)
    end

  end


end
