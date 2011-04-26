require 'ripl'

module Ripl
  module MultiLine
    VERSION = '0.2.4'

    class << self
      attr_accessor :engine
    end

    def before_loop
      super
      @buffer = nil
      # include CamelCased implementation
      require File.join( 'ripl', 'multi_line', config[:multi_line_engine].to_s )
      Ripl::MultiLine.engine = Ripl::MultiLine.const_get(
        config[:multi_line_engine].to_s.gsub(/(^|_)(\w)/){ $2.capitalize }
      )
      Ripl::Shell.include Ripl::MultiLine.engine
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
        if config[:multi_line_short_history] && @buffer && @input
          (@buffer.size + 1).times{ history.pop }
          history << (@buffer << @input).dup.map{|e| e.sub(/(;+$|^;+)/, '') }.join('; ')
        end
        @buffer = nil
      end
    end

    # an option to classify input as multi-line:
    #   overwrite this method to return true for inputs that should not get evaluated
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
    # MAYBE: terminal rewriting
    def handle_interrupt
      if @buffer
        @buffer.pop
        history.pop
        if @buffer.empty?
          @buffer = nil
          print '[buffer empty]'
          return super
        else
          puts "[previous line removed|#{@buffer.size}]"
          throw :multiline
        end
      else
        super
      end
    end

  end
end

Ripl::Shell.include Ripl::MultiLine # implementation gets included in before_loop
Ripl.config[:multi_line_engine] ||= :live # not satisfied? try :ripper or implement your own

Ripl.config[:multi_line_prompt] ||= proc do # you can also use a plain string here
  '|' + ' '*(Ripl.shell.instance_variable_get(:@prompt).size-1) # '|  '
end

Ripl.config[:multi_line_short_history] = true  if Ripl.config[:multi_line_short_history].nil?

# J-_-L
