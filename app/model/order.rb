class Order < CsvModel::Base
  define_id_field
  define_field :coupon, references: Coupon, presence: false
end
