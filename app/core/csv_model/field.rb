module CsvModel
  class Field
    attr_reader :clazz, :name

    def initialize(clazz, name, **options)
      # (clazz:, name:, presence: true, pattern: nil,
      # type: :string, enum: nil, through: nil, default: nil)

      @clazz = clazz
      @name = name
      @options = normalize_options({
        presence: true,
        type: :string
      }.merge(options))
    end

    def valid?
      @clazz.is_a?(Class) && @name.is_a?(Symbol)
    end

    def invalid?
      !valid?
    end

    def to_argument
      return if invalid?

      argument = "#{@name}: #{@options[:default]}"
      argument << 'nil' if @options.key?(:default) && @options[:default].nil?

      argument.strip
    end

    def to_assignment
      return if invalid?

      "@#{@name} = #{@name}"
    end

    def to_validity
      return if invalid?

      validity = ''

      if @options[:presence]
        validity << "\nresult = @#{@name}.present? if result"
      end

      if @options[:pattern]
        validity << "\nresult = Regexp.new(\"#{@options[:pattern]}\")" \
          ".match(@#{@name}) if result && @#{@name}"
      end

      validity
    end

    def hash
      result = 1

      [@clazz, @name].each do |field|
        result += 31 * field.hash if field
      end

      result
    end

    def ==(other)
      return @name.to_s == other.to_s unless other.is_a? Field

      eql?(other)
    end

    def eql?(other)
      other.is_a?(Field) && @clazz == other.clazz && @name == other.name
    end

    private

    def normalize_options(options)
      # set pattern
      # verify types
      options
    end
  end
end
