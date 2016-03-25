require_relative 'field_definition/field'

module CsvModel
  module FieldDefinition
    module ClassMethods
      attr_reader :fields

      def define_field(name, **options)
        define_fields name, **options
      end

      def define_fields(*names, **options)
        @fields ||= []

        names.each do |name|
          field = CsvModel::FieldDefinition::Field.new(self, name, options)

          @fields << field if field.valid? && !@fields.include?(field)
        end

        define_attr_reader
        define_initialize
      end

      def define_id_field(**options)
        define_field(:id, {
          type: :numeric
        }.merge(options))
      end

      private

      def define_attr_reader
        @fields.each do |field|
          class_eval field.to_attr_reader
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
        @fields.map(&:to_argument).join(', ')
      end

      def fields_as_assignments
        @fields.map(&:to_assignment).join("\n")
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
