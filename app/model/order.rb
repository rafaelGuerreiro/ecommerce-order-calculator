class Order
  attr_accessor :id, :coupon, :products

  def initialize(id:, coupon: nil, products: [])
    return if id.nil?

    @id = id.freeze
    @coupon = coupon
    @products = products
  end
end
