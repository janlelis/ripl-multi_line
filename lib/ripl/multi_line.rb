require 'ripl'

module Ripl
  module MultiLine
    VERSION = '0.1.3'

    def before_loop
      super
      @buffer = nil
    end

    def prompt
      @buffer ? config[:multi_line_prompt] : super
    end

    def loop_once
      catch(:multiline) do
        super
        @buffer = nil
      end
    end

    def print_eval_error(e)
      if e.is_a?(SyntaxError) && e.message =~ /unexpected \$end|unterminated string meets end of file/
        (@buffer ||= '') << @input+"\n"
        throw :multiline
      else
        super
      end
    end

    def eval_input(input)
      super(@buffer ? @buffer + input : input)
    end
  end
end

Ripl::Shell.send :include, Ripl::MultiLine
Ripl.config[:multi_line_prompt] ||= '|    '

# J-_-L
