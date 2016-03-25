require_relative 'csv_model/field_definition'

module CsvModel
  class Base
    include CsvModel::FieldDefinition
  end
end
