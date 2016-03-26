class Order < CsvModel::Base
  define_id_field
  define_field :coupon, references: Coupon, presence: false

  def products
    return @products if @products.present?

    @products = OrderProduct.find_by_order_id(@id).map(&:product).compact
  end

  def total
    @total ||= products.map(&:value).reduce(0, :+)
  end

  def total_with_discount
    @total_with_discount ||= apply_discount
  end

  private

  def apply_discount
    progressive = progressive_discount
    coupon = coupon_discount

    return (total - progressive).round(2) if coupon <= progressive

    discounted_coupon if coupon > 0

    (total - coupon).round(2)
  end

  def coupon_discount
    coupon ? coupon.calculate_discount(total) : 0
  end

  def progressive_discount
    amount = products.count

    return 0 if amount < 2

    amount = 8 if amount > 8
    percentage = amount * 5.0 / 100.0

    total * percentage
  end

  def discounted_coupon
    coupon.discount!
  end
end
