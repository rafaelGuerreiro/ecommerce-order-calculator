class Product < CsvModel::Base
  define_id_field
  define_field :value, type: :numeric
end
