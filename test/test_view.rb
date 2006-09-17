require "test/unit"
require "rubygems"
require "mocha"
require File.dirname(__FILE__) + "/../lib/init.rb"

class TestView < Test::Unit::TestCase
  include SimpleConsole

  def setup
  end

  def teardown
  end

  def test_render_action
    controller = Controller.new
    controller.set_action(:default)

    view = View.new(controller)
    view.render_action

    assert_equal(controller.params[:action], view.params[:action])
  end

  def test_render_non_existant_action
    controller = Controller.new
    view = nil

    assert_nothing_raised { view = View.new(controller) }
    assert_raise (TypeError) { view.render_action }
  end
end
