require 'common'
require 'bk'

class BKTreeQueryAccuracyTest < Test::Unit::TestCase
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
    expected = terms.inject({}){ |acc, t|
      d = Text::Levenshtein.distance(t, search_term)
      acc[t] = d if d <= threshold
      acc
    }
    assert expected.any?
    assert_equal expected, tree.query(search_term, threshold)
  end
end

class BKTreeSearchSpaceTest < Test::Unit::TestCase

  class RecordingLevenshteinDistancer < BK::LevenshteinDistancer
    attr_reader :history

    def initialize
      @history = []
      @counting = false
      @recording = false
    end

    def call(a, b)
      @history << [a, b] if @recording
      super
    end

    def start_recording
      @recording = true
    end
  end

  def test_should_compare_only_necessary_nodes
    tree = BK::Tree.new
    terms = %w[
      infighting
      birded
      inebriation
      stargazers
      troika
      bostonians
      contemplating
      gamey
      skydove
      scandalously
      archaeological
      soundness
      tightwads
      wanderlust
    ]
    distancer = RecordingLevenshteinDistancer.new
    tree = BK::Tree.new(distancer)
    terms.each do |term|
      tree.add(term)
    end
    distancer.start_recording
    tree.query('game', 1)
    expected = [
      %w[ game infighting ],
      %w[ game contemplating],
      %w[ game birded],
      %w[ game gamey ],
      %w[ game troika ],
      %w[ game skydove],
      %w[ game soundness ]
    ]
    assert_equal expected, distancer.history
  end
end

class BKTreeSearchDuplicateTest < Test::Unit::TestCase

  RandomStruct = Struct.new(:string, :random)

  class RandomStructLevenshteinDistancer
    def call(a, b)
      Text::Levenshtein.distance(a.string, b.string)
    end
  end

  def test_should_handle_many_duplicates
    tree = BK::Tree.new(RandomStructLevenshteinDistancer.new)

    10000.times do
      tree.add(RandomStruct.new('dupe', rand))
    end

    assert_equal 10000, tree.query(RandomStruct.new('dupe', rand), 0).length
  end
end
