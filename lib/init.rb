# Handles the initialization of SimpleConsole by requiring all files and putting
# the classes under the SimpleConsole module.

# SimpleConsole is a module used for building command-line applications.
# The three most important methods are SimpleConsole::Controller,
# SimpleConsole::View, and SimpleConsole::Application.
module SimpleConsole 
  class Filter
  end
  class ParamsParser
  end
  class Controller
  end
  class View
  end
  class Application
  end
end

Dir.glob(File.dirname(__FILE__) + "/*.rb").uniq.each do |file|
  require file
end
