require 'text/levenshtein'

module BK
  # See http://blog.notdot.net/archives/30-Damn-Cool-Algorithms,-Part-1-BK-Trees.html
  # and http://www.dcc.uchile.cl/~gnavarro/ps/spire98.2.ps.gz
  
  module Dumpable
    def dump
      if children.any?
        [term, children.inject({}){ |h,(score,child)| h[score] = child.dump; h }]
      else
        [term]
      end
    end
  end
  
  module DotGraphable
    def graph
      %{"#{term}" [label = "#{term}"]\n} + 
      children.sort_by{ |distance, child| distance }.map{ |distance, child|
        child.graph +
        %{edge [label = "#{distance}"]\n#{term} -> #{child.term}\n}
      }.join
    end
  end
  
  class LevenshteinDistancer
    def distance(a, b)
      Text::Levenshtein.distance(a, b)
    end
  end
  
  class Node
    include Dumpable
    include DotGraphable
    
    attr_reader :term, :children
    
    def initialize(term, distancer)
      @term = term
      @children = {}
      @distancer = distancer
    end
    
    def has_child?(score)
      !!children[score]
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
      collected << self.term if distance_at_node <= threshold
      ((threshold-distance_at_node)..(threshold+distance_at_node)).each do |score|
        child = children[score]
        child.query(term, threshold, collected) if child
      end
    end
    
    def distance(term)
      @distancer.distance(self.term, term)
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
      collected = []
      @root.query(term, threshold, collected)
      return collected
    end
  
    def dump
      @root ? @root.dump : []
    end
  
    def dot_graph
      ["digraph G {", @root.graph, "}"].join("\n")
    end
  end
  
end


require 'test/unit'

class BKTreeBuildingWhiteBoxTest < Test::Unit::TestCase

  attr_reader :tree

  def setup
    @tree = BK::Tree.new
  end
  
  def test_should_build_root
    tree.add('book')
    assert_equal ['book'], tree.dump
  end
  
  def test_should_add_one_term
    tree.add('book')
    tree.add('rook')
    assert_equal(
      [ 'book', {
        1 => [ 'rook' ]}],
      tree.dump
    )
  end
  
  def test_should_add_second_term
    tree.add('book')
    tree.add('rook')
    tree.add('nooks')
    assert_equal(
      [ 'book', {
        1 => [ 'rook' ],
        2 => [ 'nooks' ]}], 
      tree.dump
    )
  end
  
  def test_should_add_third_term
    tree.add('book')
    tree.add('rook')
    tree.add('nooks')
    tree.add('boon')
    assert_equal(
      [ 'book', {
        1 => [ 'rook', {
          2 => [ 'boon' ]}],
        2 => [ 'nooks' ]}],
      tree.dump
    )
  end
  
  def test_should_add_fourth_term
    tree.add('book')
    tree.add('rook')
    tree.add('nooks')
    tree.add('boon')
    tree.add('boot')
    assert_equal(
      [ 'book', {
        1 => [ 'rook', {
          2 => [ 'boon', {
            1 => [ 'boot' ]}]}], 
        2 => [ 'nooks' ]}],
      tree.dump
    )
  end
  
end

class BKTreeQueryingTest < Test::Unit::TestCase
  
  def test_should_match_the_results_of_a_linear_scan
    tree = BK::Tree.new
    terms = %w[ 
      lorem ipsum dolor sit amet consectetuer adipiscing elit donec eget lectus vivamus nec
      odio non ipsum adipiscing ornare etiam sapien
    ].uniq
    terms.each do |term|
      tree.add(term)
    end
    # File.open('bk.dot', 'w') do |io|
    #   io << tree.dot_graph
    # end
    search_term = 'sapient'
    distance = 1
    expected = terms.select{ |t| Text::Levenshtein.distance(t, search_term) <= distance }
    assert expected.any?
    assert_equal expected, tree.query(search_term, distance)
  end
  
end

class BKTreePerformanceTest < Test::Unit::TestCase
  
  class CountingLevenshteinDistancer < BK::LevenshteinDistancer
    attr_reader :count
    
    def initialize
      @count = 0
      @counting = false
    end
    
    def distance(a, b)
      @count += 1 if @counting
      super
    end
    
    def start_counting
      @counting = true
    end
  end
  
  def time(message)
    t0 = Time.now
    yield
    puts "%s: %0.3fs" % [message, Time.now - t0]
  end
  
  def test_should_scan_less_than_half_of_all_nodes
    terms, distancer, distance, tree, search_term, expected, actual = nil
    
    time('Loading dictionary') do
      terms = File.read('/usr/share/dict/words').scan(/\w+/)[0, 10000]
    end
    
    time('Building tree') do
      distancer = CountingLevenshteinDistancer.new
      tree = BK::Tree.new(distancer)
      terms.each do |term|
        tree.add(term)
      end
      search_term = 'alien'
      distance = 1
    end
    
    time('Linear scan to find expected terms') do
      expected = terms.select{ |t| Text::Levenshtein.distance(t, search_term) <= distance }
    end

    distancer.start_counting
    
    time('Query tree') do
      actual = tree.query(search_term, distance)
    end
    
    assert_equal expected.sort, actual.sort
    assert distancer.count < (terms.length / 2.0)
    puts '%0.1f%%' % [(distancer.count * 100.0) / terms.length]
  end
  
end
