module CsvModel
  module FieldDefinition
    module Enum
      def to_enumeration_checks(field)
        return '' unless field.enum.present?

        methods = []
        field.enum.each do |enum|
          methods << %(
            def #{enum}?
              @#{field.name} == :#{enum}
            end)
        end

        methods.join('')
      end
    end
  end
end
