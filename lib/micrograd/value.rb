# Stores a single scalar value and its gradient
module Micrograd
  class Value
    attr_reader :data, :operation, :previous
    attr_accessor :backward, :gradient, :label

    def initialize(data, children: [], operation: '', label: '')
      @data = data
      @gradient = 0.0
      @previous = children
      @operation = operation # eg '+', '-', '*', '/'
      @label = label
      @backward = -> {}
    end

    # Return a new Value object with the sum of combined data
    #  
    # = Example
    #   a = Value.new(-4.0)
    #   b = Value.new(2.0)
    #   c = a + b
    def +(other)
      other = if other.is_a?(Value)
        other
      else 
        Value.new(other)
      end

      output = Value.new(
        @data + other.data,
        children: [self, other],
        operation: '+'
      )
      
      output.backward = -> do
        @gradient += 1.0 * output.gradient
        other.gradient += 1.0 * output.gradient
      end

      output
    end

    # Return a new Value object with the product of combined data
    #  
    # = Example
    #   a = Value.new(-4.0)
    #   b = Value.new(2.0)
    #   c = a * b
    def *(other)
      other = if other.is_a?(Value)
        other
      else 
        Value.new(other)
      end

      output = Value.new(
        @data * other.data,
        children: [self, other],
        operation: '*'
      )

      output.backward = -> do
        @gradient += other.data * output.gradient
        other.gradient += @data * output.gradient
      end

      output
    end

    # Return a new Value object to the power of combined data
    #
    # = Example
    #   a = Value.new(-4.0)
    #   b = Value.new(2.0)
    #   c = a ** b
    def **(other)
      raise ArgumentError, "power must be a Numeric" unless other.is_a?(Numeric)

      output = Value.new(
        self.data**other,
        children: [self],
        operation: "**#{other}"
      )

      output.backward = -> do
        self.gradient += (other * (self.data**(other - 1))) * output.gradient
      end

      output
    end

    # Perform reverse-mode automatic differentiation starting from this value.
    #
    # This method computes the gradient of the current value with respect
    # to all preceding values in the computation graph.
    #
    # The algorithm works in three steps:
    #
    # 1. Traverse the graph to collect all dependent nodes.
    # 2. Order the nodes topologically so that each node appears
    #    after all of its inputs.
    # 3. Propagate gradients backward by invoking each node's local
    #    backward function in reverse topological order.
    #
    # Before propagation begins, the gradient of the current (root)
    # value is set to 1.0, representing d(self)/d(self).
    #
    # Each Value object is expected to define a +backward+ lambda
    # that applies the chain rule to accumulate gradients into its
    # input nodes.
    #
    # @example
    #   a = Value.new(2.0)
    #   b = Value.new(3.0)
    #   c = a * b
    #   c.backward!
    #   puts a.gradient  # => 3.0
    #   puts b.gradient  # => 2.0
    #
    # @return [void]
    def backward!
      topological_order = []
      visited = {}

      build = lambda do |value|
        return if visited[value.object_id]
        visited[value.object_id] = true
        value.previous.each { |child| build.call(child) }
        topological_order << value
      end

      build.call(self)

      # seed gradient
      self.gradient = 1.0

      topological_order.reverse_each do |v|
        v.backward.call
      end
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
