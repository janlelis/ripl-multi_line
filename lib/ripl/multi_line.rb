require 'ripl'

module Ripl
  module MultiLine
    VERSION = '0.2.4'

    def before_loop
      super
      @buffer = nil
      Ripl::Shell.include Ripl::MultiLine::Ruby if config[:multi_line_ruby]
      @ignore_mode = false
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

    # an option to classify input as multi-line:
    #   overwrite this method to return true for inputs which should not get evaluated
    def multiline?(eval_string)
      false
    end

    def handle_multiline
      @buffer ||= []
      @buffer << @input
      throw :multiline
    end
  
    def loop_eval(input)
      eval_string = if @buffer then @buffer*"\n" + "\n" + input else input end
      handle_multiline if multiline?(eval_string)
      super eval_string
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

    # Ruby specific multi-line behaviour
    module Ruby
      ERROR_REGEXP = /#{
        [ %q<unexpected \$end>,
          %q<unterminated [a-z]+ meets end of file>,
          # rubinius
          %q<expecting '.+'( or '.+')*>,
          %q<missing 'end'>,
          # jruby
          %q<syntax error, unexpected end-of-file>,
        ]*'|' }/

      def print_eval_error(e)
        if e.is_a?(SyntaxError) && e.message =~ ERROR_REGEXP
          handle_multiline
        else
          super
        end
      end

      def eval_input(input)
        if input =~ /;\s*$/ # force multi line with ;
          handle_multiline
        elsif input == '=begin'
          @ignore_mode = true # maybe TODO: change prompt
        # elsif @ignore_mode && input == '=end' # see print_result
        #   @ignore_mode = false
        else
          super unless @ignore_mode
        end
      end

      def print_result(result)
        if @ignore_mode && @input == '=end' # see print_result
          @ignore_mode = false
        elsif !@ignore_mode
          super
        end
      end

    end
  end
end

Ripl::Shell.include Ripl::MultiLine

Ripl.config[:multi_line_prompt] ||= proc do # you can also use a plain string here
  '|' + ' '*(Ripl.shell.instance_variable_get(:@prompt).size-1) # '|  '
end

Ripl.config[:multi_line_ruby] = true

# J-_-L
