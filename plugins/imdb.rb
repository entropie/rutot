#
# $Id: 133 Michael Trommer <mictro@gmail.com>: $ header added$
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "imdb"

respond_on(:PRIVMSG, :imdb, prefix_or_nick(:imdb), :args => [:Everything], :arg_req => true) do |h|

  query = h.args.join(' ')


  # TODO: rating (not supported by gem yet, possibly due html changes on imdb site)
  begin

    imdb = ::Imdb::Search.new(query.strip).movies

    if imdb.size == 0
      raise "not found"

    else
      movie = imdb.first
      r = "%s: %s" % [movie.title.strip, movie.url]
      r << "\n%s"       % [movie.plot.strip]
      r << "\nDirector: %s;  Tagline: %s; Runtime: %s" % [
                                                          movie.director,
                                                          movie.tagline,
                                                          movie.length
                                                         ]
      h.respond(r)
    end

    
    
  rescue
    h.respond(ReplyBox.NO)
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
