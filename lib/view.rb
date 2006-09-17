# The View is meant to render the output for each action in the Controller.
# Each 'view template' is just another method definition, usually with a lot of
# 'puts' method calls.  The instance variables of the Controller is injected
# into the View, so if @var is set in the controller, you can access it in the
# view.
#
# == Sample Usage
#   class MyController < SimpleConsole::Controller
#     def say_hello
#       @word = "Hello!"
#     end
#   end
#
#   class MyView < SimpleConsole::View
#     def say_hello
#       puts @word
#     end
#   end
#
#   SimpleConsole::Application.run(ARGV, MyController, MyView)
#
# == What it did
# The above example defines the action "say_hello".  So in the console:
#
#   % myapp say_hello
#   Hello!
#
# == Related Methods
# Check out SimpleConsole::Controller's render method, which can change which
# view template is rendered.
class SimpleConsole::View
  attr_accessor :params
  
  # Llinks the view to the controller
  def initialize(controller) #:nodoc
    @control = controller
  end

  # Renders the current action, the default being @control's params[:action]
  def render_action(action = @control.params[:action]) #:nodoc
    set_variables
    begin
      send(action) if respond_to?(action)
    rescue TypeError => error
      raise TypeError, "params[:action] should be set to :default if no action is given"
    end
  end

  private
  # Sets the instance variables of this view to be the same as it's @control.
  def set_variables #:nodoc
    @control.instance_variables.each do |var|
      instance_variable_set(var, @control.instance_variable_get(var))
    end
  end
end
