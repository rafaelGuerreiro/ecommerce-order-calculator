class Order
  attr_accessor :id, :coupon

  def initialize(id:, coupon:)
    return if id.nil? || price.nil?

    @id = id.freeze
    @coupon = coupon
  end
end
