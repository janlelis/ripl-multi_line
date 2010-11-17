module Ripl
  module MultiLine
    VERSION = '0.1.2'

    def before_loop
      super
      @buffer = nil
      config[:multi_line_prompt] ||= '|    '
    end

    def prompt
      @buffer ? config[:multi_line_prompt] : super
    end

    #def loop_once
    #  catch(:multiline) do
    #    super
    #    @buffer = nil
    #  end
    #end

    def print_eval_error(e)
      if e.is_a?(SyntaxError) && e.message =~ /unexpected \$end|unterminated string meets end of file/
        (@buffer ||= '') << @input+"\n"
        throw :multiline
      else
        super
      end
    end

    #def eval_input(input)
    #  super(@buffer ? @buffer + input : input)
    #end
  end

  # non-plugin api hack
  class Shell
    alias loop_once_without_multiline loop_once
    def loop_once
      catch(:multiline) do
        loop_once_without_multiline
        @buffer = nil
      end
    end

    alias eval_input_without_multiline eval_input
    def eval_input(input)
      eval_input_without_multiline(@buffer ? @buffer + input : input)
    end
  end

end

Ripl::Shell.send :include, Ripl::MultiLine if defined? Ripl::Shell

# J-_-L
