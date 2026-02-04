# Stores a single scalar value and its gradient
module Micrograd
  class Value
    attr_reader :data, :gradient, :operation, :previous

    def initialize(data, children: [], operation: '')
      @data = data
      @gradient = 0
      @previous = children
      @operation = operation # eg '+', '-', '*', '/'

      # TODO: set 
    end

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

    # Render the computation graph for this value using Graphviz.
    #
    # This is a convenience wrapper around Micrograd::Viz.draw_dot
    # that automatically uses the current value as the root.
    #
    # @param out_path [String] path to output image
    # @param type [Symbol] output format (default: :png)
    # @return [String] path to generated file
    def draw_dot(out_path: "graph.png", type: :png)
      Micrograd::Viz.draw_dot(self, out_path: out_path, type: type)
    end
  end
end
