require 'dentaku/evaluator'
require 'dentaku/token'
require 'dentaku/tokenizer'
require 'dentaku/unresolved_identifier'

module Dentaku
  class Calculator

    attr_reader :result, :tokenizer

    def initialize
      clear
    end

    def tokenizer
      @tokenizer ||= Tokenizer.new
    end

    def retain(expression)
      @tokens = tokenizer.tokenize(expression)
      @tokens.select{ |t| t.category == :identifier }.map(&:value).uniq
    end

    def execute(data={})
      store(data) do
        @evaluator ||= Evaluator.new
        @result = @evaluator.evaluate(replace_identifiers_with_values)
      end
    end

    def evaluate(expression, data={})
      @tokens = tokenizer.tokenize(expression)
      execute(data)
    end

    def memory(key=nil)
      key ? @memory[key.to_sym] : @memory
    end

    def store(key_or_hash, value=nil)
      restore = @memory.dup

      if value
        @memory[key_or_hash.to_sym] = value
      else
        key_or_hash.each do |key, value|
          @memory[key.to_sym] = value if value
        end
      end

      if block_given?
        result = yield
        @memory = restore
        return result
      end

      self
    end
    alias_method :bind, :store

    def clear
      @memory = {}
    end

    def empty?
      @memory.empty?
    end

    private

    def replace_identifiers_with_values
      @tokens.map do |token|
        if token.is?(:identifier)
          value = memory(token.value) 
          raise UnresolvedIdentifier.new(token) if value.nil?
          type  = type_for_value(value)

          Token.new(type, value)
        else
          token
        end
      end
    end

    def type_for_value(value)
      value.is_a?(String) ? :string : :numeric
    end
  end
end
