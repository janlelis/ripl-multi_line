require 'ripl'
require 'ripl/multi_line'

module Ripl::MultiLine::Live
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
    elsif input =~ /^=begin(\s.*)?$/ && !@buffer
      @ignore_mode = true # MAYBE: change prompt
    # elsif @ignore_mode && input == '=end' # see print_result
    #   @ignore_mode = false
    else
      super unless @ignore_mode
    end
  end

  def print_result(result)
    if @ignore_mode && @input == '=end'
      @ignore_mode = false
    elsif !@ignore_mode
      super
    end
  end
end

Ripl.config[:multi_line_engine] ||= :live 

# J-_-L
