module Ripl
  module MultiLine
    VERSION = '0.1.0'

    def during_loop
      input = ''
      while true do
        input = catch :multiline do
          new_input = get_input
          exit if !new_input
          input += new_input
          exit if input == 'exit'
          loop_once(input)
          puts(format_result(@last_result)) unless @error_raised
          input = ''
        end
      end
    end

    def loop_once(input)
      @last_result = loop_eval(input)
      eval("_ = Ripl.shell.last_result", @binding)
    rescue Exception => e
     if e.is_a?(SyntaxError) && e.message =~ /unexpected \$end|unterminated string meets end of file/
       throw :multiline, input + "\n"
     else
       @error_raised = true
       print_eval_error(e)
     end
    ensure
      @line += 1
    end
  end
end

Ripl::Shell.send :include, Ripl::MultiLine if defined? Ripl::Shell

# J-_-L
