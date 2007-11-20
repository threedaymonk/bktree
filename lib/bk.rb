require 'text/levenshtein'

module BK
  # Paul Battley 2007
  # See http://blog.notdot.net/archives/30-Damn-Cool-Algorithms,-Part-1-BK-Trees.html
  # and http://www.dcc.uchile.cl/~gnavarro/ps/spire98.2.ps.gz
  
  class LevenshteinDistancer
    def distance(a, b)
      Text::Levenshtein.distance(a, b)
    end
  end
  
  class Node
    attr_reader :term, :children
    
    def initialize(term, distancer)
      @term = term
      @children = {}
      @distancer = distancer
    end
    
    def add(term)
      score = distance(term)
      if child = children[score]
        child.add(term)
      else
        children[score] = Node.new(term, @distancer)
      end
    end
    
    def query(term, threshold, collected)
      distance_at_node = distance(term)
      collected[self.term] = distance_at_node if distance_at_node <= threshold
      ((distance_at_node-threshold)..(threshold+distance_at_node)).each do |score|
        child = children[score]
        child.query(term, threshold, collected) if child
      end
    end
    
    def distance(term)
      @distancer.distance(term, self.term)
    end
  end
  
  class Tree
    def initialize(distancer = LevenshteinDistancer.new)
      @root = nil
      @distancer = distancer
    end
  
    def add(term)
      if @root
        @root.add(term)
      else
        @root = Node.new(term, @distancer)
      end
    end
  
    def query(term, threshold)
      collected = {}
      @root.query(term, threshold, collected)
      return collected
    end
  end
end
