require 'yaml'

require 'bk/inserter'
require 'bk/querier'
require 'bk/levenshtein_distancer'

module BK
  class Tree
    def initialize(distancer = LevenshteinDistancer.new)
      @root = nil
      @distancer = distancer
    end

    def add(term)
      if @root
        BK::Inserter.new(@distancer).add @root, term
      else
        @root = [term]
      end
    end

    def query(term, threshold)
      BK::Querier.new(@distancer).query(@root, term, threshold)
    end

    def export(stream)
      stream.write YAML.dump(self)
    end

    def self.import(stream)
      YAML.load(stream.read)
    end
  end
end
