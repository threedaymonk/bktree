$:.unshift( File.join( File.dirname(__FILE__), '..', 'lib' ))
require 'test/unit'
require 'bk'

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

    search_term = 'sapient'
    threshold = 1
    expected = terms.select{ |t| Text::Levenshtein.distance(t, search_term) <= threshold }
    assert expected.any?
    assert_equal expected, tree.query(search_term, threshold)
  end
end
