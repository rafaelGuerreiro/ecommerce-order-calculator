class Coupon < CsvModel::Base
  define_id_field
  define_field :value, type: :numeric
  define_field :discount_type, enum: [:absolute, :percent]
  define_field :expiration, type: :date
  define_field :usage_limit, type: :numeric

  def expired?
    return false if invalid?

    Date.new > @expiration || @usage_limit < 1
  end

  def active?
    return false if invalid?

    !expired?
  end
end
