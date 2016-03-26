class OrderProduct < CsvModel::Base
  define_field :order, references: Order
  define_field :product, references: Product

  def id
    return if invalid?
    @id ||= order_id.to_s + product_id.to_s
  end
end
