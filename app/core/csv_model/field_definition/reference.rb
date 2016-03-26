module CsvModel
  module FieldDefinition
    module Reference
      def to_reference_attr_reader
        %(
          def #{@name}_id
            @#{@name}
          end

          def #{@name}
            @#{@name}_instance ||= #{@options[:references]}.find(@#{@name})
          end)
      end
    end
  end
end
