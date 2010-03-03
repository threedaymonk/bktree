require 'bk'

module BK
  module Dumpable
    def dump
      if children.any?
        [term, children.inject({}){ |h,(score,child)| h[score] = child.dump; h }]
      else
        [term]
      end
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
