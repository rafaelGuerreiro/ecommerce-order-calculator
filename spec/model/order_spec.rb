describe Order, :model do
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
        '123,',
        '234,123',
        '345,234',
        '456,345',
        '567,456',
        '678,567',
        '1000,567',
        '567,',
        ',123',
        ',',
        ' , ',
        ','
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
  end
end
