require 'text/levenshtein'
require 'yaml'

module BK
  # Paul Battley 2007
  # See http://blog.notdot.net/archives/30-Damn-Cool-Algorithms,-Part-1-BK-Trees.html
  # and http://www.dcc.uchile.cl/~gnavarro/ps/spire98.2.ps.gz

  class LevenshteinDistancer
    def call(a, b)
      Text::Levenshtein.distance(a, b)
    end
  end

  class Node
    attr_reader :term, :equal_terms, :children

    def initialize(term, distancer)
      @term = term
      @equal_terms = []
      @children = {}
      @distancer = distancer
    end

    def add(term)
      score = distance(term)
      if score == 0
        @equal_terms << term
      elsif child = children[score]
        child.add(term)
      else
        children[score] = Node.new(term, @distancer)
      end
    end

    def query(term, threshold, collected)
      distance_at_node = distance(term)
      if distance_at_node <= threshold
        collected[self.term] = distance_at_node
        @equal_terms.each do |t|
          collected[t] = distance_at_node
        end
      end
      ((distance_at_node-threshold)..(threshold+distance_at_node)).each do |score|
        child = children[score]
        child.query(term, threshold, collected) if child
      end
    end

    def distance(term)
      @distancer.call term, self.term
    end

    def depth
      1 + (children.map { |_, c| c.depth }.max || 0)
    end
  end

  class Tree
    def initialize(distancer = LevenshteinDistancer.new)
      @root = nil
      @distancer = distancer
    end

    def add(term)
      if @root
        @root.add term
      else
        @root = Node.new(term, @distancer)
      end
    end

    def depth
      if @root
        @root.depth
      else
        0
      end
    end

    def query(term, threshold)
      collected = {}
      @root.query term, threshold, collected
      return collected
    end

    def export(stream)
      stream.write YAML.dump(self)
    end

    def self.import(stream)
      YAML.load(stream.read)
    end
  end
end
