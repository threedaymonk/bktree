require 'common'
require 'bk'
require 'bk/dump'

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
    %w[ book rook nooks ].each do |word|
      tree.add(word)
    end
    assert_equal(
      [ 'book', {
        1 => [ 'rook' ],
        2 => [ 'nooks' ]}],
      tree.dump
    )
  end

  def test_should_add_third_term
    %w[ book rook nooks boon ].each do |word|
      tree.add(word)
    end
    assert_equal(
      [ 'book', {
        1 => [ 'rook', {
          2 => [ 'boon' ]}],
        2 => [ 'nooks' ]}],
      tree.dump
    )
  end

  def test_should_add_fourth_term
    %w[ book rook nooks boon boot ].each do |word|
      tree.add(word)
    end
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
