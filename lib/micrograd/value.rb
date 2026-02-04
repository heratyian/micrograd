##
# Stores a single scalar value and its gradient
module Micrograd
  class Value
    attr_reader :data, :gradient

    def initialize(data, children: [], operation: '')
      @data = data
      @gradient = 0
      @previous = children
      @operation = operation # eg '+', '-', '*', '/'

      # TODO: set 
    end

    ##
    #  Return a new Value object with the combined data
    #  
    #  = Example
    #   a = Micrograd::Value.new(-4.0)
    #   b = Micrograd::Value.new(2.0)
    #   c = a + b
    def +(other)
      other = if is_a?(Value)
        other
      else 
        Value.new(other)
      end

      output = Value.new(
        @data + other.data,
        children: [self, other],
        operation: '+'
      )

      # TODO: set backward

      output
    end
  end
end
