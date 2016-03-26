require_relative 'csv_model/field_definition'
require_relative 'csv_model/loader'
require_relative 'csv_model/persist'
require_relative 'csv_model/file_dump'

module CsvModel
  class Base
    include CsvModel::FieldDefinition
    include CsvModel::Loader
    include CsvModel::Persist
    include CsvModel::FileDump

    def valid?
      return false unless respond_to? :id
      valid = true

      fields = self.class.fields
      valid = all_fields_valid?(fields) if fields.present?

      valid
    end

    def invalid?
      !valid?
    end

    module ClassMethods
      include Enumerable

      def each(&block)
        all.each(&block)
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    private

    def all_fields_valid?(fields)
      valid = true

      fields.each do |field|
        break unless valid
        next unless field.validable?

        valid = field_valid?(field)
      end

      valid
    end

    def field_valid?(field)
      value = instance_variable_get("@#{field.name}")
      field.value_valid?(value)
    end
  end
end
