require 'bk'

module BK
  module DotGraphable
    def graph
      %{"#{term}" [label = "#{term}"]\n} +
      children.sort_by{ |distance, child| distance }.map{ |distance, child|
        child.graph +
        %{edge [label = "#{distance}"]\n"#{term}" -> "#{child.term}"\n}
      }.join
    end
  end

  class Node
    include DotGraphable
  end

  class Tree
    def dot_graph
      ["digraph G {", @root.graph, "}"].join("\n")
    end
  end
end
