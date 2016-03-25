class Coupon < CsvModel::Base
  define_id_field
  define_field :value, type: :numeric
  define_field :discount_type, enum: [:absolute, :percent]
  define_field :expiration, type: :date
  define_field :usage_limit, type: :numeric

  def expired?
  end
end
