module BK
  class Inserter
    def initialize(distancer)
      @distancer = distancer
    end

    def add(node, term)
      node << {} if node.length == 1
      node_term, children = node

      score = distance(term, node_term)
      child_with_same_score = children[score]

      if child_with_same_score
        add child_with_same_score, term
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
