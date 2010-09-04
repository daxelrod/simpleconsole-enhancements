class SimpleConsole::ParamsParser
  def initialize
    @letter_to_key ||= Hash.new
    @key_types ||= Hash.new
    @letter_types ||= Hash.new
    @error_list ||= Array.new
    @valid_param_list ||= Array.new
    @valid_param_key_list ||= Array.new
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
      if arg =~ /^--(.*)$/
        argument = $1
        value = argv[argv.index(arg) + 1]
        if @letter_to_key.has_value?(argument.to_sym)
          params[argument.to_sym] = get_value_of(value, argument.to_sym)
          add_valid(arg, argument.to_sym)
        else
          add_error(arg)
        end
      elsif arg =~ /^-(.)/
        argument = $1
        value = argv[argv.index(arg) + 1]
        if @letter_to_key.has_key?(argument.to_sym)
          argument = @letter_to_key[argument.to_sym]
          params[argument.to_sym] = get_value_of(value, argument.to_sym)
          add_valid(arg, argument.to_sym)
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

  def valid_params
    @valid_param_list ||=Array.new
    return @valid_param_list
  end

  def valid_param_keys
    @valid_param_key_list ||=Array.new
    return @valid_param_key_list
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

  def add_valid(arg, key)
    @valid_param_list ||= Array.new
    @valid_param_key_list ||= Array.new
    @valid_param_list << arg
    @valid_param_key_list << key
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
