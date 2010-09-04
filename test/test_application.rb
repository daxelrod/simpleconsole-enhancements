require "test/unit"
require "rubygems"
require "mocha"
require File.dirname(__FILE__) + "/../lib/init.rb"

class AppControl < SimpleConsole::Controller
  def method_missing(method_name)
  end
end

class TwoAppControl < SimpleConsole::Controller
end

class TestApplication < Test::Unit::TestCase
  include SimpleConsole

  def setup
    @call_chain = [:call_before_filter_for, :call_after_filter_for]
  end

  def teardown
  end

  # Sets a controller object to pass into Application.run
  def set_control(method_call = nil)
    control = mock
    control.expects(:new).at_least_once.returns(control)
    control.expects(:execute_action).at_least_once
    control.expects(:params).at_least_once.returns({:action => method_call})
    control.expects(:set_action).at_least_once
    control.expects(:set_params).at_least_once
    
    control.expects(method_call).at_least_once if method_call

    return control
  end

  # Sets a view object to pass into Application.run
  def set_view
    view = mock
    view.expects(:new).at_least_once.returns(view)
    view.expects(:render_action).at_least_once

    return view
  end

  def test_basic_control_run
    Application.stubs(:control_implements?).returns(false)

    # Run with default action, only controller no view
    Application.run(Array.new, set_control(:default))
  end

  # Run tests where the controller and view don't implement action
  def test_control_view_no_action_run
    # Run with method_missing because neither controller or view has action
    Application.run([:action], AppControl, set_view)
  end
end

