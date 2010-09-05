require "test/unit"
require "rubygems"
require "mocha"
require "set"
require File.dirname(__FILE__) + "/../lib/init.rb"

  def assert_same_set(expected, result)
    assert_equal(expected.to_set, result.to_set)
  end

# SampleController for tests usage.
# :say_hi should be followed by a :say_bye
# :bye should be prepended with a :hello
class SampleController < SimpleConsole::Controller
  params :int => { :i => :integer },
         :string => { :n => :name, :t => :title },
         :text => { :d => :description },
         :bool => { :o => :open, :c => :closed}

  before_filter :say_hi, :only => [:say_bye]
  after_filter :bye, :except => [:say_bye]

  def say_bye; "bye"; end

  def hello; "hello"; end

  def default; redirect_to :action => :say_bye; raise "I shouldn't raise"; end

  def say_hi; "hi"; end
  
  def bye; "goodbye"; end

  public :invalid_params, :invalid_params?, :valid_params, :valid_param_keys #So that we can call these from the tests below
end

class TestController < Test::Unit::TestCase
  def setup
    @control = SampleController.new
  end

  def teardown
  end

  def test_filters_for_execute_action
    @control.expects(:say_hi).at_least_once
    @control.expects(:say_bye).at_least_once
    @control.set_action(:say_bye)
    @control.execute_action

    @control.expects(:hello).times(1)
    @control.expects(:bye).times(1)
    @control.set_action(:hello)
    @control.execute_action
  end

  def test_no_filters
    control = SimpleConsole::Controller.new

    assert_raise(NoMethodError) { control.execute_action } 
  end

  def test_execute_action_with_redirect
    control = SampleController.new    
    control.expects(:say_bye).at_least_once
    assert_nothing_raised(RuntimeError) { control.execute_action }
  end

  def test_params
    control = SampleController.new
    control.set_params %w(-i 1 --name Hugh -t Mr --description programmer --open)

    assert_equal(control.params[:integer], 1)
    assert_equal(control.params[:name], "Hugh")
    assert_equal(control.params[:title], "Mr")
    assert_equal(control.params[:description], "programmer")
    assert_equal(control.params[:open], true)
    assert_equal(control.params[:closed], nil)
  end

  def test_param_validity
    control = SampleController.new
    control.set_params %w(-i 1 --name Hugh -t Mr --description programmer --open --monkey Macaque -q invalid)

    expected_keys = [:integer, :name, :title, :description, :open] 

    assert(control.send(:invalid_params?), "There are invalid parameters")
    assert_same_set(%w(--monkey -q), control.invalid_params)
    assert_same_set(%w(-i --name -t --description --open), control.valid_params)
    assert_same_set(expected_keys, control.valid_param_keys)

    control.valid_param_keys.each do |key|
      assert(control.params.has_key?(key), "params has valid key #{key.inspect}")
    end
  end

end
