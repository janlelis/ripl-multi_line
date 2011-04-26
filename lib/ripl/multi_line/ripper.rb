# see https://github.com/cldwalker/ripl-ripper/blob/master/lib/ripl/ripper.rb for a standalone plugin
require 'ripl'
require 'ripl/multi_line'
require 'ripper'

module Ripl::MultiLine::Ripper
  def multiline?(string) #FIXME allow string literals?
    !Ripper::SexpBuilder.new(string).parse
  end
end

Ripl.config[:multi_line_engine] ||= :ripper

# J-_-L
