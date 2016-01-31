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

  class Tree
    def initialize(distancer = LevenshteinDistancer.new)
      @root = nil
      @distancer = distancer
    end

    def add(term)
      if @root
        add_ @root, term
      else
        @root = [term]
      end
    end

    def query(term, threshold)
      collected = {}
      query_ @root, term, threshold, collected
      return collected
    end

    def export(stream)
      stream.write YAML.dump(self)
    end

    def self.import(stream)
      YAML.load(stream.read)
    end

  private

    def add_(node, term)
      node << {} if node.length == 1
      node_term, children = node
      score = distance(node_term, term)
      if child = children[score]
        add_ child, term
      else
        children[score] = [term]
      end
    end

    def query_(node, term, threshold, collected)
      node_term, children = node
      distance_at_node = distance(term, node_term)
      collected[node_term] = distance_at_node if distance_at_node <= threshold
      return unless children
      (-threshold..threshold).each do |d|
        child = children[distance_at_node + d]
        next unless child
        query_ child, term, threshold, collected
      end
    end

    def distance(a, b)
      @distancer.call a, b
    end
  end
end
