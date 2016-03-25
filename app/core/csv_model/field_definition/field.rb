require_relative 'argument'
require_relative 'assignment'
require_relative 'enum'
require_relative 'validator'

module CsvModel
  module FieldDefinition
    class Field
      include CsvModel::FieldDefinition::Argument
      include CsvModel::FieldDefinition::Assignment
      include CsvModel::FieldDefinition::Enum
      include CsvModel::FieldDefinition::Validator

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
    end
  end
end
