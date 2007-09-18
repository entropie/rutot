#
# $Id: 126 Michael Trommer <mictro@gmail.com>: fix-line-spaces$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Rutot

  module Contribs

    @@contribs ||= { }

    module Box; end

    ContribDirectory = File.dirname(__FILE__) + "/contrib"

    def self.contribs
      @@contribs
    end

    def self.[](which)
      unless @@contribs[which.to_sym].nil?
        puts :CNT, "choosing contrib from cache"
        return @@contribs[which.to_sym]
      end

      puts :CNT, "trying to load `#{which}´"
      contribdir = File.join(ContribDirectory, which.to_s)
      newbox = Module.new{ include Box }
      newbox.module_eval %q{
        def self.getBinding
          binding
        end
      }
      Dir["#{contribdir}/*.rb"].push(File.join("lib/#{which}.rb")).each do |contriblib|
        unless File.exists?(contriblib)
          puts :ERR, "#{contriblib} does not exists"
        else
          eval(File.readlines(contriblib).join, newbox.getBinding)
          puts :CNT, "loading: #{contriblib}"
        end
      end
      @@contribs[which.to_sym] = newbox
      newbox
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
