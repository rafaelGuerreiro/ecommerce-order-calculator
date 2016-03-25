require_relative 'csv_model/field_definition'
require_relative 'csv_model/loader'

module CsvModel
  class Base
    include CsvModel::FieldDefinition
    include CsvModel::Loader

    def valid?
      return false unless respond_to? :id

      valid = true

      fields = self.class.fields
      fields.each do |field|
        break unless valid
        next unless field.validable?

        value = instance_variable_get("@#{field.name}")
        valid = field.value_valid?(value)
      end

      valid
    end

    def invalid?
      !valid?
    end
  end
end
