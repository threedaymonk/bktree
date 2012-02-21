$:.unshift( File.join( File.dirname(__FILE__), '..', 'lib' ))
require 'bk'

class CountingLevenshteinDistancer < BK::LevenshteinDistancer
  attr_reader :count

  def initialize
    @count = 0
    @counting = false
  end

  def call(a, b)
    @count += 1 if @counting
    super
  end

  def start_counting
    @counting = true
  end
end

def time(message)
  t0 = Time.now
  print "#{message} ... "
  $stdout.flush
  retval = yield
  puts "%0.3fs" % [Time.now - t0]
  return retval
end

search_term = 'alien'
threshold = 1
distancer = CountingLevenshteinDistancer.new

terms = time('Loading 10 K words from dictionary'){
  File.read('/usr/share/dict/words').scan(/\w+/)[0, 10000]
}

tree = time('Building tree'){
  tree = BK::Tree.new(distancer)
  terms.each do |term|
    tree.add(term)
  end
  tree
}

expected = time('Linear scan to find expected terms'){
  terms.inject({}){ |acc, t|
    d = Text::Levenshtein.distance(t, search_term)
    acc[t] = d if d <= threshold
    acc
  }
}

distancer.start_counting

actual = time('Query tree'){
  tree.query(search_term, threshold)
}

raise 'Results of linear and tree scan differ' unless expected == actual

puts '%0.1f%% of tree was queried' % [(distancer.count * 100.0) / terms.length]
