require 'ripl'

module Ripl
  module MultiLine
    VERSION = '0.2.0'
    ERROR_REGEXP = /#{
      [ %q%unexpected $end%,
        %q%unterminated string meets end of file%,
        # rubinius
        %q%expecting '\\n' or ';'%,
        %q%missing 'end'%,
        %q%expecting '}'%,
        # jruby
        %q%syntax error, unexpected end-of-file%,
      ].map{|e| Regexp.escape(e)}*'|' }/

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

      if e.is_a?(SyntaxError) && e.message =~ ERROR_REGEXP
        @buffer ||= []
        @buffer << @input
        throw :multiline
      else
        super
      end
    end
  
    def loop_eval(input)
      if @buffer
        super @buffer*"\n" + "\n" + input
      else
        super input
      end
    end

    # remove last line from buffer
    # TODO: nicer interface (rewriting?)
    def handle_interrupt
      if @buffer
        @buffer.pop
        if @buffer.empty?
          @buffer = nil
          return super
        else
          puts "[previous line removed]"
          throw :multiline
        end
      else
        super
      end
    end
  end
end

Ripl::Shell.send :include, Ripl::MultiLine
Ripl.config[:multi_line_prompt] ||= '|    '

# J-_-L
