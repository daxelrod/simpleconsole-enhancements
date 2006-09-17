require "test/unit"
require File.dirname(__FILE__) + "/../lib/init.rb"

class TestFilter < Test::Unit::TestCase
  def setup
    @filter = SimpleConsole::Filter.new
  end

  def teardown
  end

  def filter_chain
    return @filter.instance_variable_get(:@filter_chain)
  end

  def assert_similar_arrays(expected, actual)
    expected.each do |item|
      assert(actual.include?(item))
    end

    actual.each do |item|
      assert(expected.include?(item))
    end
  end

  def test_add_filter_without_arguments
    assert_raise(ArgumentError) { @filter.add_filter }
  end

  def test_filter_all
    filters = Array.new
    methods = [:one, :two, :three, :four, :five]

    methods.each do |method|
      filters << method
      @filter.add_filter method

      assert_similar_arrays(filters, @filter.filter_for(:random))
    end
  end

  def test_filter_only
    filters = Hash.new
    filters[:one] = [:method_one, :method1, :one_method]
    filters[:two] = [:method_two, :method2, :two_method]
    filters[:three] = [:method_three, :method3, :three_method]
    filters[:all] = filters[:one] + filters[:two] + filters[:three]

    filters.each do |filter, methods|
      methods.each { |method| @filter.add_filter method, :only => [filter, :all] } unless filter == :all
    end

    filters.each do |filter, methods|
      assert_similar_arrays(methods, @filter.filter_for(filter))
    end
  end

  def test_filter_except
    filters = Hash.new

    ones = [:method_one, :method1, :one_method]
    twos = [:method_two, :method2, :two_method]
    threes = [:method_three, :method3, :three_method]

    filters[:one] = twos + threes
    filters[:two] = ones + threes
    filters[:three] = ones + twos

    ones.each { |m| @filter.add_filter m, :except => [:one] }
    twos.each { |m| @filter.add_filter m, :except => [:two] }
    threes.each { |m| @filter.add_filter m, :except => [:three] }

    filters.each do |filter, methods|
      assert_similar_arrays(methods, @filter.filter_for(filter))
    end
  end
end
