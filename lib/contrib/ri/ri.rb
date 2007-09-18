#
# $Id: 109 Michael Trommer <mictro@gmail.com>: ri plugin and plugins from rbot: thefightcrime, insult$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Ri

  Ri = 'fri -f simple -T'

  def self.[](m)
    ret =
      begin
        `#{Ri} #{m}`.split("\n").reject{ |l| l.strip.empty? || l =~ /^----/}
      rescue
        raise "failed to execute fri"
      end
    ret
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
