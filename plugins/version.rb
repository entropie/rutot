#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

respond_on(:PRIVMSG, :version, prefix_or_nick(:version)) do |h|
  nams = %w'bot dood guy bird gay mate cop criminal MACHINE'.sort_by{ rand }.first
  strs = [
          'tasty',
          'sinister',
          'all seeing',
          'pragmatic',
          'lost',
          'bugfree™',
          'supernatural',
          'dumb',
          'pleasant',
          'friendly'
         ].sort_by{ rand }.first
  h.respond("Rutlov, the #{strs} Ruby #{nams}.  Version: %s" % Rutot.version +
    "\nSee ,source?")
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
