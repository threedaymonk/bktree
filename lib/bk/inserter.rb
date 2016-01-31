module BK
  class Inserter
    def initialize(distancer)
      @distancer = distancer
    end

    def add(node, term)
      node << {} if node.length == 1
      node_term, children = node
      score = distance(node_term, term)
      if child = children[score]
        add child, term
      else
        children[score] = [term]
      end
    end

  private

    def distance(a, b)
      @distancer.call a, b
    end
  end
end
