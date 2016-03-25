module CsvModel
  module FieldDefinition
    class Field
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

      def validable?
        valid? && (@options[:presence] || @options[:pattern])
      end

      def value_valid?(value)
        return false unless validable?

        valid = true

        valid = value.present? if @options[:presence]

        if @options[:pattern] && valid && value
          valid = @options[:pattern].match(value.to_s).present?
        end

        valid
      end

      def to_argument
        return if invalid?

        argument = "#{@name}: "
        argument << 'nil' unless @options[:default]
        argument << @options[:default].inspect if @options[:default]

        argument.strip
      end

      def to_assignment
        return if invalid?

        assignment = ''
        space = "\n          "

        assignment << date_assignment + space if @options[:type] == :date
        assignment << number_assignment + space if @options[:type] == :numeric

        assignment << "@#{@name} = #{@name}"
      end

      def to_attr_reader
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
        options[:type] = :numeric if options[:references].is_a?(CsvModel::Base)

        if options[:enum].present?
          options[:type] = :enum
          options[:pattern] = Regexp.new("(#{options[:enum].join('|')})")
        end
      end

      def date_assignment
        %(
          begin
            if #{@name}.is_a?(String)
              #{@name} = Date.strptime(#{@name}, '%Y/%m/%d')
            end
          rescue ArgumentError
            #{@name} = nil
          end)
      end

      def number_assignment
        %(
          begin
            if #{@name}.is_a?(String)
              if #{@name}.include?('.')
                #{@name} = Float(#{@name})
              else
                #{@name} = Integer(#{@name})
              end
            end
          rescue ArgumentError
            #{@name} = nil
          end)
      end
    end
  end
end
