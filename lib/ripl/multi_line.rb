require 'ripl'

module Ripl
  module MultiLine
    VERSION = '0.2.4'

    class << self
      attr_accessor :engine
    end

    def before_loop
      super
      @buffer = @buffer_info = nil
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
            config[:multi_line_prompt].call( *@buffer_info[-1] ) :
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
        if config[:multi_line_history] && ( config[:multi_line_history] == :compact ) && @buffer && @input
          (@buffer.size + 1).times{ history.pop }
          history_entry = ''
          @buffer.zip(@buffer_info){ |str, type|
            history_entry << str
            history_entry << case
            when type[0] == :statement
              '; '
            when type[0] == :literal && ( type[1] == :string || type[1] == :regexp )
              '\n'
            else
              ''
            end
          }
          history_entry << @input
          history << history_entry
        end
        @buffer = @buffer_info = nil
      end
    end

    # an option to classify input as multi-line:
    #   overwrite this method to return true for inputs that should not get evaluated
    def multiline?(eval_string)
      false
    end

    def handle_multiline(type = :statement) # MAYBE: add second arg for specifc information
      @buffer ||= []
      @buffer_info ||= []
      @buffer << @input
      @buffer_info << type
      throw :multiline
    end
  
    def loop_eval(input)
      eval_string = if @buffer then @buffer*"\n" + "\n" + input else input end
      if type = multiline?(eval_string)
        handle_multiline(type)
      end
      super eval_string
    end

    # remove last line from buffer
    # MAYBE: terminal rewriting
    def handle_interrupt
      if @buffer
        @buffer.pop; @buffer_info.pop; history.pop
        if @buffer.empty?
          @buffer = @buffer_info = nil
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
Ripl.config[:multi_line_engine] ||= :live_error # not satisfied? try :ripper or implement your own

Ripl.config[:multi_line_prompt] ||= proc do # you can also use a plain string here
  '|' + ' '*(Ripl.shell.instance_variable_get(:@prompt).size-1) # '|  '
end

Ripl.config[:multi_line_history] = :compact  if Ripl.config[:multi_line_history].nil?

# J-_-L
