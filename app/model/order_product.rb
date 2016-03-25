class OrderProduct < CsvModel::Base
  define_field :order, references: Order
  define_field :product, references: Product
end
