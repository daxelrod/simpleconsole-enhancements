require "test/unit"
require File.dirname(__FILE__) + "/../lib/init.rb"

class TestParamsParser < Test::Unit::TestCase
  def setup
    @parser = SimpleConsole::ParamsParser.new
  end

  def teardown
  end

  def assert_same_hash(expected, result)
    expected.each do |key, value|
      assert(result.has_key?(key) && result.has_value?(value))
      assert_equal(value, result[key])
    end

    result.each do |key, value|
      assert(expected.has_key?(key) && expected.has_value?(value))
      assert_equal(value, expected[key])
    end
  end

  def test_int
    @parser.int_params(:i => :id, :f => :float)
    argv = ["-i", "1", "--float", "2"]

    assert_same_hash({:id => 1, :float => 2}, @parser.argv_to_params(argv))
  end

  def test_bool
    @parser.bool_params(:o => :open, :c => :close)
    argv = ["-o", "doesn't matter", "--close", "--open"]

    assert_same_hash({:open => true, :close => true}, @parser.argv_to_params(argv))
  end

  def test_text
    @parser.text_params(:d => :description, :t => :text)
    argv = ["-d", "a description", "--text", "the text"]
    
    assert_same_hash({:description => "a description", :text => "the text"}, @parser.argv_to_params(argv))
  end

  def test_string
    @parser.string_params(:s => :string, :t => :title)
    argv = ["-s", "a string", "--title", "the title"]

    assert_same_hash({:string => "a string", :title => "the title"}, @parser.argv_to_params(argv))
  end
end
