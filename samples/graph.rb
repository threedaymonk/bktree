$:.unshift( File.join( File.dirname(__FILE__), '..', 'lib' ))
require 'bk'
require 'bk/dot_graph'

tree = BK::Tree.new
$stdin.each_with_index do |line, i|
  tree.add(line.strip)
  File.open('bk-%04d.dot' % i, 'w') do |io|
    io << tree.dot_graph
  end
end
