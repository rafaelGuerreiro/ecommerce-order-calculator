class Order
  attr_accessor :id, :coupon

  def initialize(id:, coupon:)
    if id.nil? || price.nil?
      return
    end

    @id = id.freeze
    @coupon = coupon
  end
end
