require 'ripl'
require 'ruby_parser'

Ripl.config[:multi_line_engine] ||= :ruby_parser
require 'ripl/multi_line'

module Ripl::MultiLine::RubyParser
  VERSION = '0.1.0'

  ERROR_MESSAGES = [
    [[:literal, :string], /unterminated string meets end of file/],
    # [[:literal, :regexp], /unterminated regexp meets end of file/],          #-> string
    # [[:literal, :array],  /syntax error, unexpected \$end, expecting '\]'/], #-> ParseError
    [[:literal, :hash],   /syntax error, unexpected \$end, expecting '\}'/],   # {45
  ]

  def multiline?(string)
    return [:forced] if string =~ /;\s*\Z/ # force multi line with ;
    ::RubyParser.new.parse(string)
    false # string was parsable, no multi-line
  rescue ::Racc::ParseError
    [:statement]
  rescue SyntaxError => e
    ERROR_MESSAGES.each{ |type, message|
      return type if message === e.message
    }
    false # syntax error not multi-line relevant
  end
end

# J-_-L
