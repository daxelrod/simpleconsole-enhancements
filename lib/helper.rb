module SimpleConsole::TestHelper
  def run(action, params)
    @control.params = params
    SimpleConsole::Application.run([action.to_sym], @control, @view)
  end

  def output
    return @output.string
  end

  def initialize_data
    @control.instance_variables.each do |var|
      define_method(var.to_s.gsub("^@", "")) do
        return @control.instance_variable_get(var)
      end
    end
  end

end
