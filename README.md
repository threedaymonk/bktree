# BK-Tree implementation in Ruby

BK-trees can be used to efficiently locate strings' best matches from within a large set. If you don’t know what a BK-tree is, these links should provide a good explanation and introduction.

* [Damn Cool Algorithms, Part 1: BK-Trees](http://blog.notdot.net/2007/4/Damn-Cool-Algorithms-Part-1-BK-Trees)
* [Fast Approximate String Matching in a Dictionary](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.21.3317)


## Installation

BK is available as a ruby gem:

    gem install bk

## Usage

    require "bk"
    tree = BK::Tree.new # Use the default Levenshtein distance algorithm

Add items to the tree:

    tree.add "cat"
    tree.add "dog"
    tree.add "monkey"
    tree.add "donkey"

Find all items within distance 1 of ‘munkey’:

    tree.query("munkey", 1)
    # => {"monkey"=>1} 

Find all items within distance 2 of ‘munkey’:

    tree.query("munkey", 2)
    # => {"donkey"=>2, "monkey"=>1}

You can specify a custom distance algorithm by passing an object that responds
to `call(a, b)` with a number:

    custom_algorithm = lambda{ |a, b|
      Text::Levenshtein.distance(a, b)
    }

    tree = BK::Tree.new(custom_algorithm)

Note that the result *must* satisfy the
_triangle inequality_, i.e. _d(x,z) ≤ d(x,y) + d(y,z)_.

The precomputed tree can be exported to and reimported later from an IO-like object:

    File.open("tree", "wb") do |f|
      tree.export(f)
    end

    File.open("tree", "rb") do |f|
      tree = BK::Tree.import(f)
    end

## Dependencies

* [text](http://rubygems.org/gems/text) version 0.2.0 or newer.

## Performance

Results of looking for words within distance 1 of ‘alien’ in a 20,000-word dictionary:

    Loading 20000 words from dictionary ... 0.273s
    Building tree ... 57.331s
    Linear scan to find expected terms ... 5.711s
    Query tree ... 0.133s
    2.1% of tree was queried

This means that the BK-tree is about 40 times as fast as a linear search,
although building the initial tree took 10 times as long as a linear search.

As the threshold increases, the benefit is reduced. At threshold 3:

    Query tree ... 3.368s
    62.9% of tree was queried

## Limitations

* Memory usage: around 6 MB for a 20,000-word tree.
* Maximum tree depth is limited by the stack.

## Testing

    rake test

...or, for specific tests:

    ruby test/test_building_tree.rb

## License

(TO DO)
