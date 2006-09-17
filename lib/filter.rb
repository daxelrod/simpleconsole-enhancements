# This class keeps track of filters - much like Rails filters for
# ActionController.
#
# == Sample Usage
#
#   before_filter = Filter.new
#   before_filter.add_filter :first
#   before_filter.add_filter :second, :only => [:use_me]
#   before_filter.add_filter :third, :except => [:use_me]
#
#   before_filter.filter_for(:use_me)
#   # => Returns [:first, :second]
class SimpleConsole::Filter

  # Initializes the filter
  def initialize
    @filter_chain = Hash.new
  end

  # Adds a method call to the current filter.  Options include:
  # * :except => Array
  # * :only => Array
  #
  # == Sample Usage
  #
  #   chain = Filter.new
  #   chain.add_filter(:first)                       
  #   chain.add_filter(:second, :only => [:use_me]) 
  #   chain.add_filter(:third, :except => [:dont_use_me])
  #   # => Adds :first to all, :second only to :use_me, and :third to all except :dont_use_me
  def add_filter(method_to_call, options = nil)
    if options == nil
      @filter_chain[method_to_call.to_sym] = true
    elsif options.has_key?(:only)
      @filter_chain[method_to_call.to_sym] = Hash.new
      @filter_chain[method_to_call.to_sym][:only] = options[:only]
    elsif options.has_key?(:except)
      @filter_chain[method_to_call.to_sym] = Hash.new
      @filter_chain[method_to_call.to_sym][:except] = options[:except]
    end
  end

  # Returns a list of the methods in the filter for method_name.
  #
  # == Example Usage
  #
  #   chain = Filter.new
  #   chain.add_filter(:first, :second)
  #   chain.add_filter(:third, :fourth, :only => [:call_me])
  #   chain.add_filter(:fifth, :sixth, :except => [:call_me])
  #
  #   filter_for(:call_me)
  #   # => [:first, :second, :third, :fourth, :fifth]
  def filter_for(method_name)
    methods = Array.new
    
    @filter_chain.each do |method_to_call, option|
      if option == true
        methods << method_to_call
      elsif option.has_key?(:only) && option[:only].include?(method_name.to_sym)
        methods << method_to_call 
      elsif option.has_key?(:except) && !option[:except].include?(method_name.to_sym)
        methods << method_to_call 
      end
    end

    return methods.uniq
  end
end
