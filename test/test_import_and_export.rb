require 'common'
require 'bk'
require 'stringio'

class BKTreeImportAndExportTest < Test::Unit::TestCase
  def test_should_give_correct_results_after_exporting_and_reimporting
    tree = BK::Tree.new
    terms = %w[
      lorem ipsum dolor sit amet consectetuer adipiscing elit donec eget lectus vivamus nec
      odio non ipsum adipiscing ornare etiam sapien
    ].uniq
    terms.each do |term|
      tree.add(term)
    end

    stream = StringIO.new
    tree.export(stream)

    stream.rewind
    tree = BK::Tree.import(stream)

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
