module CsvModel
  module FieldDefinition
    module Argument
      def to_argument
        return if invalid?

        argument = "#{@name}: "
        argument << 'nil' unless @options[:default]
        argument << @options[:default].inspect if @options[:default]

        argument.strip
      end
    end
  end
end
