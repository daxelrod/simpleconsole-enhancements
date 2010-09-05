class SimpleConsole::ParamsParser
  def initialize
    @letter_to_key ||= Hash.new
    @key_types ||= Hash.new
    @letter_types ||= Hash.new
    @error_list ||= Array.new
  end

  def int_params(list) 
    set_key(list, :int) 
  end

  def text_params(list)
    set_key(list, :text)
  end

  def string_params(list)
    set_key(list, :string)
  end

  def bool_params(list)
    set_key(list, :bool)
  end

  def argv_to_params(argv)
    params = Hash.new
    @letter_to_key ||= Hash.new
    argv.each do |arg|
      if arg =~ /^-(-?)(.+)$/
        second_dash = $1
        argument = $2

        argument_equals_split = argument.split("=")
        argument, value = case argument_equals_split.size
        when 1
          [argument, argv[argv.index(arg) + 1]]
        when 2
          argument_equals_split
        else #Consider --foo=bar=baz malformed
          add_error(arg)
          next
        end

        found = nil
        if ((second_dash == '') && (argument.length == 1)) #If we were passed a one-letter argument
          found = @letter_to_key.has_key?(argument.to_sym)
          argument = @letter_to_key[argument.to_sym] if found
        else
          found = @letter_to_key.has_value?(argument.to_sym)
        end

        if found
          params[argument.to_sym] = get_value_of(value, argument.to_sym)
        else
          add_error(arg)
        end
      end
    end

    return params
  end

  def invalid_params
    @error_list ||= Array.new
    return @error_list
  end
  
  private
  def set_key(list, type)
    return if !list
    @letter_to_key ||= Hash.new
    @key_types ||= Hash.new
    @letter_types ||= Hash.new
    @letter_to_key.update(list)
    list.each do |letter, key| 
      @key_types[key] = type 
      @letter_types[letter] = type 
    end
  end

  def add_error(error)
    @error_list ||= Array.new
    @error_list << error
  end

  def get_value_of(value, key)
    type = @key_types[key] if @key_types.has_key?(key)
    type = @letter_types[key] if @letter_types.has_key?(key)

    if type == :int
      return value.to_i
    elsif type == :text
      return value.to_s
    elsif type == :string
      return value.to_s
    elsif type == :bool
      return true
    end
  end
end
