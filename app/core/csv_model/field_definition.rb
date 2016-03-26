require_relative 'field_definition/field'

module CsvModel
  module FieldDefinition
    module ClassMethods
      def define_field(name, **options)
        define_fields name, **options
      end

      def define_fields(*names, **options)
        @fields ||= {}

        names.each do |name|
          field = CsvModel::FieldDefinition::Field.new(self, name, options)

          @fields[name] = field if field.valid? && !@fields.key?(name)
        end

        define_attr_reader
        define_initialize
        define_enumeration_checks
      end

      def define_id_field(**options)
        define_field(:id, {
          type: :numeric
        }.merge(options))
      end

      def fields(name = nil)
        return [] unless @fields

        return @fields[name] if @fields.key?(name)

        @fields.values
      end

      def options(name, option)
        return unless name.is_a?(Symbol) && option.is_a?(Symbol)
        field = @fields[name] if @fields.key?(name)

        return field.options[option] if field
      end

      private

      def define_attr_reader
        @fields.each_value do |field|
          class_eval field.to_attr_reader if field.valid?
        end
      end

      def define_initialize
        init = %(
          def initialize(#{fields_as_arguments})
            #{fields_as_assignments}
          end
        )

        class_eval init
      end

      def fields_as_arguments
        fields.map(&:to_argument).join(', ')
      end

      def fields_as_assignments
        fields.map(&:to_assignment).join("\n")
      end

      def define_enumeration_checks
        checks = fields.map(&:to_enumeration_checks).join("\n")
        class_eval checks if checks.present?
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
