require 'bk'

module BK
  module Dumpable
    def dump
      children_dump = children.inject({}){ |h,(score,child)| h[score] = child.dump; h }
      [
        term,
        equal_terms.empty? ? nil : equal_terms,
        children_dump.empty? ? nil : children_dump
      ].compact
    end
  end

  class Node
    include Dumpable
  end

  class Tree
    def dump
      @root ? @root.dump : []
    end
  end
end
