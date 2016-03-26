module CsvModel
  module FieldDefinition
    module Enum
      def to_enumeration_checks
        return '' unless valid? && @options[:enum].present?

        methods = []
        @options[:enum].each do |enum|
          methods << %(
            def #{enum}?
              @#{@name} == :#{enum}
            end)
        end

        methods.join('')
      end
    end
  end
end
