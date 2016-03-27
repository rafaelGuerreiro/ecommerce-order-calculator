describe Order, :model do
  before do
    CsvModelRepository.destroy!
  end

  describe '.fields' do
    it 'returns the header used for parsing the csv' do
      fields = Order.fields
      expect(fields).to have(2).fields

      expect(fields[0].name).to eq(:id)
      expect(fields[1].name).to eq(:coupon)
    end
  end

  describe '.load' do
    before do
      csv_data = [
        '123,', '234,123', '345,234',
        '456,345', '567,456', '678,567',
        '1000,567', '567,', ',123',
        ',', ' , ', ','
      ]
      file_path = 'orders.csv'
      stub_csv_file file_path, csv_data.join("\n")
    end

    it 'loads all valid orders' do
      orders = Order.load 'orders'

      expect(orders).to have(7).orders
    end
  end

  describe '#coupon' do
    it 'fetches the Coupon' do
      Coupon.create id: 15,
                    value: 20,
                    discount_type: :percent,
                    expiration: Date.new + 1,
                    usage_limit: 1

      obj = Order.new(id: 12, coupon: 15)

      expect(obj.id).to eq(12)
      expect(obj.coupon_id).to eq(15)

      expect(obj.coupon).to_not be_nil
      expect(obj.coupon.id).to eq(15)
      expect(obj.coupon.expired?).to be_falsy
    end

    it 'returns nil when the Coupon does not exist' do
      obj = Order.new(id: 15, coupon: 120)

      expect(obj.id).to eq(15)
      expect(obj.coupon_id).to eq(120)

      expect(obj.coupon).to be_nil
    end

    it 'is lazy and will fetch the Coupon only when needed' do
      obj = Order.new(id: 20, coupon: 125)

      expect(obj.id).to eq(20)
      expect(obj.coupon_id).to eq(125)

      expect(obj.coupon).to be_nil

      Coupon.create id: 125,
                    value: 15,
                    discount_type: :absolute,
                    expiration: Date.new - 1,
                    usage_limit: 0

      expect(obj.coupon).to_not be_nil
      expect(obj.coupon.id).to eq(125)
      expect(obj.coupon.expired?).to be_truthy
    end

    it 'is optional, thus the order is valid without coupon' do
      obj = Order.new(id: 16)

      expect(obj.id).to eq(16)
      expect(obj).to be_valid
      expect(obj.coupon_id).to be_nil
      expect(obj.coupon).to be_nil
    end
  end

  describe '#total' do
    it "returns zero when there's no product" do
      obj = Order.new(id: 16)
      expect(obj.total).to eq(0)
    end

    it 'sums all product prices' do
      create_product order: 17, product: 1, value: 12.5
      create_product order: 17, product: 2, value: 50
      create_product order: 17, product: 3, value: 75
      create_product order: 17, product: 4, value: 10
      create_product order: 17, product: 5, value: 15.5

      obj = Order.new(id: 17)
      expect(obj.total).to eq(163)
    end
  end

  describe '#total_with_discount' do
    it "returns zero when there's no product even with valid coupon" do
      Coupon.create id: 12,
                    value: 10,
                    discount_type: :percent,
                    expiration: Date.new + 1,
                    usage_limit: 1

      obj = Order.new(id: 16, coupon: 12)
      expect(obj.total).to eq(0)
      expect(obj.total_with_discount).to eq(0)
    end

    it 'applies 25% off because there are 5 products and no coupon' do
      create_products order: 17, values: [12.5, 50, 75, 10, 15.5]

      obj = Order.new(id: 17)
      expect(obj.total).to eq(163)
      expect(obj.total_with_discount).to eq(122.25)
    end

    it "has no discount when there's only one product and no coupon" do
      create_product order: 17, product: 1, value: 100

      obj = Order.new(id: 17)
      expect(obj.total).to eq(100)
      expect(obj.total_with_discount).to eq(100)
    end

    it 'applies at most 40% off because there are 10 products and no coupon' do
      create_products order: 17,
                      values: [
                        12.5, 50, 75, 10, 15.5,
                        80, 72, 49.90, 79.99, 99.99
                      ]

      obj = Order.new(id: 17)
      expect(obj.total).to eq(544.88)
      expect(obj.total_with_discount).to eq(326.93)
    end

    it 'applies 25% off because there are 5 products and a lower coupon' do
      coupon = Coupon.create id: 12,
                             value: 40,
                             discount_type: :absolute,
                             expiration: Date.new + 1,
                             usage_limit: 1

      create_products order: 17, values: [12.5, 50, 75, 10, 15.5]

      obj = Order.new(id: 17, coupon: 12)

      expect(coupon.expired?).to be_falsy

      expect(obj.total).to eq(163)
      expect(obj.total_with_discount).to eq(122.25)

      expect(coupon.expired?).to be_falsy
    end

    it "applies -0.01 when there's only one product and a coupon" do
      coupon = Coupon.create id: 12,
                             value: 0.01,
                             discount_type: :absolute,
                             expiration: Date.new + 1,
                             usage_limit: 1

      create_product order: 17, product: 1, value: 100

      obj = Order.new(id: 17, coupon: 12)

      expect(coupon.expired?).to be_falsy

      expect(obj.total).to eq(100)
      expect(obj.total_with_discount).to eq(99.99)

      expect(coupon.expired?).to be_truthy
    end

    it 'applies progressive discount because there are 10 products ' \
      'and a lower coupon' do
      coupon = Coupon.create id: 12,
                             value: 39.99,
                             discount_type: :percent,
                             expiration: Date.new + 1,
                             usage_limit: 1

      create_products order: 17,
                      values: [
                        12.5, 50, 75, 10, 15.5,
                        80, 72, 49.90, 79.99, 99.99
                      ]

      obj = Order.new(id: 17, coupon: 12)

      expect(coupon.expired?).to be_falsy

      expect(obj.total).to eq(544.88)
      expect(obj.total_with_discount).to eq(326.93)

      expect(coupon.expired?).to be_falsy
    end

    it 'applies coupon discount because there are 10 products ' \
      'but a higher coupon' do
      coupon = Coupon.create id: 12,
                             value: 60,
                             discount_type: :percent,
                             expiration: Date.new + 1,
                             usage_limit: 1

      create_products order: 17,
                      values: [
                        12.5, 50, 75, 10, 15.5,
                        80, 72, 49.90, 79.99, 99.99
                      ]

      obj = Order.new(id: 17, coupon: 12)

      expect(coupon.expired?).to be_falsy

      expect(obj.total).to eq(544.88)
      expect(obj.total_with_discount).to eq(217.95)

      expect(coupon.expired?).to be_truthy
    end

    it 'applies coupon discount and the order ends up being free' do
      coupon = Coupon.create id: 12,
                             value: 600,
                             discount_type: :absolute,
                             expiration: Date.new + 1,
                             usage_limit: 1

      create_products order: 17,
                      values: [
                        12.5, 50, 75, 10, 15.5,
                        80, 72, 49.90, 79.99, 99.99
                      ]

      obj = Order.new(id: 17, coupon: 12)

      expect(coupon.expired?).to be_falsy

      expect(obj.total).to eq(544.88)
      expect(obj.total_with_discount).to eq(0)

      expect(coupon.expired?).to be_truthy
    end

    it 'uses the coupon only once before it expires' do
      coupon = Coupon.create id: 12,
                             value: 30,
                             discount_type: :percent,
                             expiration: Date.new + 1,
                             usage_limit: 1

      create_products order: 17, values: [12.5, 50, 75, 10, 15.5]
      obj = Order.new(id: 17, coupon: 12)

      expect(coupon.expired?).to be_falsy

      expect(obj.total).to eq(163)
      expect(obj.total_with_discount).to eq(114.10)

      expect(coupon.expired?).to be_truthy

      create_products order: 13, values: [25, 88, 110, 99.99]
      obj = Order.new(id: 13, coupon: 12)

      expect(obj.total).to eq(322.99)
      expect(obj.total_with_discount).to_not eq(226.09)
      expect(obj.total_with_discount).to eq(258.39)
    end
  end

  def create_products(order:, values: [])
    values.each_with_index do |value, index|
      create_product(order: order, product: (order * (index + 1)), value: value)
    end
  end

  def create_product(order:, product:, value:)
    OrderProduct.create(order: order, product: product)
    Product.create(id: product, value: value)
  end
end
