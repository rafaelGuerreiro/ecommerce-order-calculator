module CsvModel
  module FieldDefinition
    module Validator
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
    end
  end
end
