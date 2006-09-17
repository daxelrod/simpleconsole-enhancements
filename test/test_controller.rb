require "test/unit"
require "rubygems"
require "stubba"
require File.dirname(__FILE__) + "/../lib/init.rb"

# SampleController for tests usage.
# :say_hi should be followed by a :say_bye
# :bye should be prepended with a :hello
class SampleController < SimpleConsole::Controller
  before_filter :say_hi, :only => [:say_bye]
  after_filter :bye, :except => [:say_bye]

  def say_bye; "bye"; end

  def hello; "hello"; end

  def default; redirect_to :action => :say_bye; raise "I shouldn't raise"; end

  def say_hi; "hi"; end
  
  def bye; "goodbye"; end
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

end
