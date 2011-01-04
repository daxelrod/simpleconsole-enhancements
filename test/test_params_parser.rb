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

  def test_invalid
    @parser.string_params(:s => :string, :t => :title)
    argv = ["--string", "string", "-i", "short_invalid", "--inv", "long_invalid"]
    assert_same_hash({:string => "string"}, @parser.argv_to_params(argv))
    assert_equal(["-i", "--inv"].sort, @parser.invalid_params.sort)
  end

  def test_ambiguous
    @parser.string_params(:s => :string, :i => :strike)
    argv = ["--string", "string", "--str", "ambiguous"]
    assert_same_hash({:string => "string"}, @parser.argv_to_params(argv))
    assert_equal(["--str"], @parser.invalid_params)
  end

  def test_equals_format
    @parser.string_params(:s => :string, :t => :title, :n => :name)
    argv = ["--string=a string", "--title=title", "--name=Dan=great"]

    assert_same_hash({:string => "a string", :title => "title", :name => "Dan=great"}, @parser.argv_to_params(argv))
  end

  def test_single_nospace_format
    @parser.string_params(:s => :string, :t => :title, :n => :name)
    argv = ["-sstring", "-ttitle", "-nDan=great"]

    assert_same_hash({:string => "string", :title => "title", :name => "Dan=great"}, @parser.argv_to_params(argv))
  end

  def test_preserve_argv

    #Always test that at least one arg is preserved,
    #since the test script is usually invoked without args
    ARGV << "sentinel"

    orig_global_argv = ARGV

    @parser.string_params(:s => :string)
    supplied_argv = ["-s" "hello"]
    
    @parser.argv_to_params(supplied_argv)

    assert_equal(orig_global_argv, ARGV)
  end
end
