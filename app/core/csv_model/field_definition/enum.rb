module CsvModel
  module FieldDefinition
    module Enum
      def to_enumeration_checks
        return '' unless @options[:enum].present?

        methods = []
        @options[:enum].each do |enum|
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
