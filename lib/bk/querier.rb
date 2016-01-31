module BK
  class Querier
    def initialize(distancer)
      @distancer = distancer
    end

    def query(node, term, threshold, collected = {})
      node_term, children = node
      distance_at_node = distance(term, node_term)
      collected[node_term] = distance_at_node if distance_at_node <= threshold

      if children
        (-threshold..threshold).each do |d|
          child = children[distance_at_node + d]
          query child, term, threshold, collected if child
        end
      end

      collected
    end

  private

    def distance(a, b)
      @distancer.call a, b
    end
  end
end
