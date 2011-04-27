# see https://github.com/cldwalker/ripl-ripper/blob/master/lib/ripl/ripper.rb for a different (standalone) plugin
require 'ripl'
require 'ripper'

Ripl.config[:multi_line_engine] ||= :ripper_pure
require 'ripl/multi_line'

# rely completely on ripper, no detailed info
module Ripl::MultiLine::RipperPure
  VERSION = '0.1.0'

  def multiline?(string)
    !!::Ripper::SexpBuilder.new(string).parse
  end
end


# J-_-L
