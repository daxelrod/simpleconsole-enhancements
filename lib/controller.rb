require File.dirname(__FILE__) + "/filter.rb"

# The Controller defines _actions_ for the application.  Each _action_ can be 
# implemented as an instance method.
#
# == Sample Usage
#   # .. inside controller.rb
#   class MyController < SimpleConsole::Controller
#     def say_hello
#       puts "hello!"
#     end
#   end
#
#   # .. inside myapp
#   # ..
#   Application.run(ARGV, MyController)
#
# == What it did
# The above example defines the action "say_hello".  So in the console:
#
#   % myapp say_hello
#   hello!
#
# == Related Methods
# Check out the "before_filter" and "after_filter" methods, similar to the
# methods implemented in Rails.
class SimpleConsole::Controller
  attr_accessor :params, :argv

  # Filter for methods to call previous to an action
  @@before_chain = SimpleConsole::Filter.new

  # Filter for methods to call after an action occurs
  @@after_chain = SimpleConsole::Filter.new

  # Keeps track of param types
  @@params_parser = SimpleConsole::ParamsParser.new
    
  # Initializes the "params" hash and creates a new Controller.  Not needed when
  # developing an application with SimpleConsole.
  def initialize()
    @params = Hash.new
    @argv = Array.new
  end

  # Returns true if the controller defines the action given, otherwise returns
  # false (returns false on private methods, also).
  def respond_to?(action)
    if @@block_action.include?(action.to_s)
      return false
    elsif private_methods.include?(action.to_s)
      return false
    else
      super
    end
  end

  # Sets the controller's params hash when given ARGV.
  def set_params(argv)
    # Set params[:id]
    id = argv[1] if argv[1] && argv[1] !~ /^-/
    if id.to_i == 0 && id != "0"
      params[:id] = id
    else
      params[:id] = id.to_i 
    end
    params.update(@@params_parser.argv_to_params(argv))
    argv.concat(argv)
  end

  # Sets the current action to the new action parameter. 
  def set_action(action)
    params[:action] = action
  end

  # Executes in order:
  #   before_filter_for action
  #   actual action
  #   after_filter_for action
  def execute_action
    begin
      params[:action] ||= :default
      call_before_filter_for(params[:action])
      send(params[:action]) if respond_to?(params[:action])
      call_after_filter_for(params[:action])
    rescue RuntimeError => error
      raise error unless error.message == "Simple::Console Redirection"
    end
  end
  
  protected
  # When the view is rendered, this action is used instead
  # == Example Usage
  #   render(:action => :new_view)
  def render(parameters)
    params.update(parameters)
  end

  # A redirect will discontinue the current action and redirect to the new one
  # with the updated params.
  # == Example Usage
  #   redirect_to(:action => :new_action)
  def redirect_to(parameters)
    params.update(parameters)
    execute_action
    raise RuntimeError, "Simple::Console Redirection"
  end

  # Returns an array of options that weren't specified by the params call.
  # == Example Usage
  #   params :string => {:f => :first, :s => :second},
  #          :int => {:t => :third}
  #   before_filter :check_params
  #   # ...
  #   def check_params
  #     puts "Invalid option(s): " + invalid_params.join(", ")
  #   end
  # == On the command line
  #   myapp --first one -t 3 --fourth oops --fifth huh?
  #   Invalid option(s): --fourth, --fifth
  def invalid_params
    return @@params_parser.invalid_params
  end

  # Returns true if the user gave any invalid options.  To retrieve the list of
  # invalid options use the method invalid_params.
  def invalid_params?
    return true if @@params_parser.invalid_params.size > 0
    return false
  end

  # Returns an array of user-supplied options that weren't specified by the
  # params call.
  # == Example Usage
  #   params :string => {:f => :first, :s => :second},
  #          :int => {:t => :third}
  #   before_filter :check_params
  #   # ...
  #   def check_params
  #     puts "Invalid option(s): " + invalid_params.join(", ")
  #     puts "Valid option(s): " + valid_params.join(", ")
  #   end
  # == On the command line
  #   myapp --first one -t 3 --fourth oops --fifth huh?
  #   Invalid option(s): --fourth, --fifth
  #   Valid option(s): --first -t
  #
  def valid_params
    return @@params_parser.valid_params
  end

  private
  # Calls all methods from "before_filter" for the given method.
  #   controller.call_before_filter_for(:method)
  # This will look for all "before_filter" :actions that are hooked onto
  # :method and execute them right before :method is called.
  def call_before_filter_for(method_name)
    @@before_chain.filter_for(method_name).each do |method|
      self.send(method)  
    end
  end

  # Similar to "call_before_filter_for" except for the "after_filter".
  def call_after_filter_for(method_name)
    @@after_chain.filter_for(method_name).each do |method|
      self.send(method)  
    end
  end

  protected
  # Executes a method before certain actions. 
  #   before_filter :method  
  #   before_filter :method, :only => [:only_before_this_method] 
  #   before_filter :method, :except => [:not_for_this_method!]
  #
  # == Sample Usage
  #   class MyController < SimpleConsole::Controller
  #     before_filter :say_hello, :only => [:say_bye]
  #
  #     def say_bye
  #       puts "bye!"
  #     end
  #
  #     private
  #     def say_hello
  #       puts "hello!"
  #     end
  #   end
  #
  # Now whenever the action "say_bye" is executed, "say_hello" is executed right
  # before it:
  #
  #   % myapp say_bye
  #   hello!
  #   bye!
  def self.before_filter(method_to_call, options = nil)
    @@before_chain.add_filter(method_to_call, options)
  end

  # Similar to "before_filter", except these methods are executed _AFTER_ 
  # certain actions.
  def self.after_filter(method_to_call, options = nil)
    @@after_chain.add_filter(method_to_call, options)
  end

  # Sets the params that are accepted in a controller.
  #   params :string => { :l => :long_name }
  #
  # Now, for your application:
  #   % myapp action -l this_is_a_parameter
  #
  # This will result in 'params[:long_name] = "this_is_a_parameter"'
  # Types include :string, :int, :text, and :bool.
  #
  # == Sample Usage
  #   class MyController < SimpleConsole::Controller
  #     params :int => { :i => :integer },
  #            :string => { :n => :name, :t => :title },
  #            :text => { :d => :description },
  #            :bool => { :o => :open, :c => :closed}
  #     
  #     # ...
  #   end
  #
  # On the command line:
  #   % myapp action -i 1 --name Hugh -t Mr --description programmer --open
  #
  # In the controller, the params hash is set for each key using the long name:
  #   params[:integer] = 1
  #   params[:name] = "Hugh"
  #   params[:title] = "Mr"
  #   params[:description] = "programmer"
  #   params[:open] = true
  #   params[:closed] = nil  # because the -c or --closed switch wasn't set
  def self.params(list)
    @@params_parser.int_params(list[:int]) 
    @@params_parser.string_params(list[:string])
    @@params_parser.bool_params(list[:bool])
    @@params_parser.text_params(list[:text])
  end

  # block all of these methods from being controller actions
  @@block_action = self.new.methods

end
