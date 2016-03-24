module CsvModel
  class Field # rubocop:disable Metrics/ClassLength
    attr_reader :clazz, :name, :options

    def initialize(clazz, name, **options)
      @clazz = clazz
      @name = name
      @options = normalize_options(options)
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

      if (@options.key?(:default) && @options[:default].nil?) ||
         (!@options.key?(:default) && !@options[:presence])

        argument << 'nil'
      end

      argument.strip
    end

    def to_assignment # rubocop:disable Metrics/MethodLength
      return if invalid?

      if @options[:type] == :date
        return %(
          if #{@name}.is_a?(Date)
            @#{@name} = #{@name}.strftime('%Y/%m/%d')
          else
            @#{@name} = #{@name}
          end
        )
      end

      "@#{@name} = #{@name}"
    end

    def to_validity
      return if invalid?

      validity = ''

      if @options[:presence]
        validity << "\nresult = @#{@name}.present? if result"
      end

      if @options[:pattern]
        validity << "\nresult = Regexp.new(\"#{stringfied_pattern}\")" \
          ".match(@#{@name}.to_s).present? if result && @#{@name}"
      end

      validity
    end

    def to_attr_reader
      if @options[:type] == :date
        return %(
          def #{@name}
            return @#{@name} if @#{@name}.is_a? Date

            Date.strptime(@#{@name}, '%Y/%m/%d')
          end
        )
      end

      "attr_reader :#{@name}"
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
      options = merge_default(options)

      delete_unknown_keys(options)
      normalize_types(options)

      options.freeze
    end

    def merge_default(options)
      {
        presence: true,
        type: :string
      }.merge(options)
    end

    def delete_unknown_keys(options)
      valid_keys = [:presence, :pattern, :type, :enum, :references, :default]
      options.delete_if { |key, _| !valid_keys.include?(key) }
    end

    def normalize_types(options)
      options[:type] = :numeric if options[:references].is_a? CsvModel

      if options[:enum].present?
        options[:type] = :enum
        options[:pattern] = Regexp.new("(#{options[:enum].join('|')})")
      end

      include_default_patterns(options)
    end

    def include_default_patterns(options)
      unless options[:pattern].present?
        {
          numeric: /\A\d*\.?\d+\z/,
          date: %r(\A\d{4}\/\d{2}\/\d{2}\z)
        }.each do |type, pattern|
          options[:pattern] = pattern if options[:type] == type
        end
      end
    end

    def stringfied_pattern
      @options[:pattern].to_s.gsub(/\\/, '\\' * 4)
    end
  end
end
