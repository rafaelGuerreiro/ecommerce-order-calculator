class Product
  attr_accessor :id, :price

  def initialize(id:, price:)
    if id.nil? || price.nil?
      return
    end

    @id = id.freeze
    @price = price.freeze
  end
end
