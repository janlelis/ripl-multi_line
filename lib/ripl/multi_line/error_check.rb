require 'ripl'

Ripl.config[:multi_line_engine] ||= :error_check
require 'ripl/multi_line'
require 'ripl/multi_line/live_error'

# # # #
# This multi-line implementation uses IRB's RubyLex parser
#   works on:         1.9  1.8  jruby  rbx
#   analyze features: see live_error.rb
#   known issues:     see live_error.rb
module Ripl::MultiLine::ErrorCheck
  VERSION = '0.1.0'

  ruby_engine = defined?(RUBY_ENGINE) && RUBY_ENGINE.downcase.to_sym
  ruby_engine = :ruby if !Ripl::MultiLine::LiveError::ERROR_MESSAGES.keys.include?(ruby_engine)

  define_method(:multiline?) do |string|
    break [:forced] if string =~ /;\s*\Z/ # force multi line with ;

    begin
      eval "if nil; #{string}; end"
    rescue SyntaxError => e
      Ripl::MultiLine::LiveError::ERROR_MESSAGES[ruby_engine].each{ |type, message|
        break type if message === e.message
      }
    end
  end
end

# J-_-L
