require "ruby-graphviz"

module Micrograd
  # Visualization utilities for inspecting autograd computation graphs.
  #
  # This module provides methods for traversing a Micrograd::Value
  # computation graph and rendering it using Graphviz.
  #
  # The visualizer mirrors the behavior of Andrej Karpathy's Python
  # micrograd draw_dot function, producing a readable graph of
  # values, gradients, and operations.
  module Viz
    module_function

    # Traverses the computation graph starting from a root value
    # and collects all reachable nodes and edges.
    #
    # This method performs a depth-first search following the
    # +previous+ references of each Value object.
    #
    # @param root [Micrograd::Value] the final value to trace from
    # @return [Array<Array<Micrograd::Value>, Array<Array>>]
    #   a tuple of [nodes, edges] where:
    #   - nodes is an array of unique Value objects
    #   - edges is an array of [child, parent] pairs
    def trace(root)
      nodes = {}
      edges = []

      walk = lambda do |v|
        return if nodes[v.object_id]

        nodes[v.object_id] = v

        v.previous.each do |child|
          edges << [child, v]
          walk.call(child)
        end
      end

      walk.call(root)
      [nodes.values, edges]
    end

    # Render the computation graph of a Value as an image file using Graphviz.
    #
    # Each Value node is displayed as a record containing:
    # - the scalar data value
    # - the gradient value
    #
    # Operation nodes are displayed as circular nodes connecting
    # input values to result values.
    #
    # @example Basic usage
    #   x = Micrograd::Value.new(2.0)
    #   y = Micrograd::Value.new(3.0)
    #   z = x * y
    #   Micrograd::Viz.draw_dot(z, out_path: "graph.png")
    #
    # @param root [Micrograd::Value] the final value whose graph should be drawn
    # @param out_path [String] path where the output image will be written
    # @param type [Symbol] graphviz output format (e.g. :png, :svg, :pdf)
    #
    # @return [String] the path to the generated image file
    def draw_dot(root, out_path: "graph.png", type: :png)
      nodes, edges = trace(root)

      g = GraphViz.new(:G, type: :digraph)

      # Left-to-right layout similar to the original micrograd visualizer
      g[:rankdir] = "LR"

      node_map = {}

      nodes.each do |n|
        uid = n.object_id.to_s

        label = "{data #{n.data.round(4)} | gradient #{n.gradient.round(4)}}"

        node_map[uid] = g.add_nodes(
          uid,
          label: label,
          shape: "record"
        )

        # If the node represents the result of an operation,
        # create an intermediate operation node
        if n.operation && !n.operation.empty?
          operation_id = "#{uid}_operation"

          node_map[operation_id] = g.add_nodes(
            operation_id,
            label: n.operation,
            shape: "circle"
          )

          g.add_edges(operation_id, uid)
        end
      end

      # Connect child values to their parent operations
      edges.each do |child, parent|
        from = child.object_id.to_s

        to =
          if parent.operation && !parent.operation.empty?
            "#{parent.object_id}_operation"
          else
            parent.object_id.to_s
          end

        g.add_edges(from, to)
      end

      g.output(type => out_path)
      out_path
    end
  end
end
