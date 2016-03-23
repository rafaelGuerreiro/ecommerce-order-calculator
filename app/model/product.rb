class Product
  attr_accessor :id, :price

  def initialize(id:, price:)
    return if id.nil? || price.nil?

    @id = id.freeze
    @price = price.freeze
  end
end
