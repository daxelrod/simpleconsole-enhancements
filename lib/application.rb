# Runs the application with the given controller and view.
#
# == Sample Usage
# Inside the script myapp:
#
#   #!/usr/bin/env ruby -w
#   require "rubygems"
#   require "simpleconsole"
#   require "your_files_with_controller_and_view.rb"
#
#   Application.run(ARGV, ControllerClassConstant, ViewClassConstant)
#   # .. the ViewClassConstant is optional, so run(ARGV, ControllerClassConstant) is valid
#
# From the command line:
#
#   myapp [action] [id] [options]
#   myapp action id --key value
#
# * action - this will be implemented as a method in the controller and/or view
# * id - this is accessible in the controller/view as params[:id]
# * options - will become available through the params hash.  So "--key value" will be params[:key] = value.
#
# == Routing Rules
# * Usually, ARGV is passed to argv for parsing and execution.
# * ARGV[0] is taken to be the _action_ to execute
# * In the case that ARGV[0] does not exist, then the controller and view are called with the method 'default'.
# * If controller_klass implements _action_ as a method, it is executed.
# * If view_klass implements _action_ as a method, it is executed after the controller.
# * If there is no view_klass, no _action_ is taken for the view.
# * If the _action_ only exists in the controller_klass or view_klass, only that single _action_ is executed and no errors are raised.
# * If no _action_ exists in the controller_klass or view_klass, controller_klass's _method_missing_ is called and the view is ignored.
class SimpleConsole::Application

  # This is the method to call to run your program from the top-level script.
  # Check out the rdoc on SimpleConsole::Application for usage.
  def self.run(argv, controller_klass, view_klass = nil)
    @@control = controller_klass.new
    @@view = view_klass ? view_klass.new(@@control) : nil
    @@control.set_params(argv)
    @@control.set_action(argv[0] || :default)

    @@control.execute_action
    @@view.render_action unless @@view.nil?

    @@control.method_missing(@@control.params[:action]) if !control_implements? && !view_implements?
  end

  private
  # Does the controller implement this action?
  def self.control_implements?
    return @@control.respond_to?(@@control.params[:action])
  end

  # Does the view implement this action?
  def self.view_implements?
    return !@@view.nil? && @@view.respond_to?(@@control.params[:action])
  end

end
