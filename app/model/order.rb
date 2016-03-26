class Order < CsvModel::Base
  define_id_field
  define_field :coupon, references: Coupon, presence: false

  def products
    @products ||= OrderProduct.find_by_order_id(@id).map(&:product)
  end
end
