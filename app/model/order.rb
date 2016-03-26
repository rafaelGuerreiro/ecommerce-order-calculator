class Order < CsvModel::Base
  define_id_field
  define_field :coupon, references: Coupon, presence: false

  # define_field :products, has_many: Product,
  #                         through: OrderProduct,
  #                         presence: false

  def products
    OrderProduct.find_by(order: @id).map(&:product)
  end
end
