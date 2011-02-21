require 'ripl'

module Ripl
  module MultiLine
    VERSION = '0.2.2'
    ERROR_REGEXP = /#{
      [ %q%unexpected \$end%,
        %q%unterminated [a-z]+ meets end of file%,
        # rubinius
        %q%expecting '\\n' or ';'%,
        %q%missing 'end'%,
        %q%expecting '}'%,
        # jruby
        %q%syntax error, unexpected end-of-file%,
      ]*'|' }/

    def before_loop
      super
      @buffer = nil
    end

    def prompt
      if @buffer
        config[:multi_line_prompt].respond_to?(:call) ? 
            config[:multi_line_prompt].call :
            config[:multi_line_prompt]
      else
        super
      end
    rescue StandardError, SyntaxError
      warn "ripl: Error while creating prompt:\n"+ format_error($!)
      Ripl::Shell::OPTIONS[:prompt]
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

Ripl::Shell.include Ripl::MultiLine
Ripl.config[:multi_line_prompt] ||= proc do
  '|' + ' '*(Ripl.shell.instance_variable_get(:@prompt).size-1) #'|    '
end

# J-_-L
