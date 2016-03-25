require_relative 'csv_model/field_definition'
require_relative 'csv_model/loader'

module CsvModel
  class Base
    include CsvModel::FieldDefinition
    include CsvModel::Loader
  end
end
