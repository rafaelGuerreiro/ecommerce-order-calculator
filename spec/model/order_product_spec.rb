describe OrderProduct, :model do
  describe '.fields' do
    it 'returns the header used for parsing the csv' do
      fields = OrderProduct.fields
      expect(fields).to have(2).fields

      expect(fields[0].name).to eq(:order)
      expect(fields[1].name).to eq(:product)
    end
  end

  describe '.load' do
    before do
      csv_data = [
        '123,789', '123,987', '234,678',
        '234,890', '234,987', '345,345',
        '345,876', '456,234', '456,234',
        '456,345', '567,123', '567,234',
        '567,876', '567,890', '567,678',
        '567,567', '678,789', '678,789',
        '678,890'
      ]
      file_path = 'order_products.csv'
      stub_csv_file(file_path: file_path, csv_data: csv_data)
    end

    it 'loads all valid order_products' do
      order_products = OrderProduct.load 'order_products'

      expect(order_products).to have(17).order_products
    end
  end

  describe '#id' do
    it 'concatenates the order id and the product id' do
      obj = OrderProduct.new(order: 12, product: 15)

      expect(obj.id).to eq('1215')
      expect(obj.order_id).to eq(12)
      expect(obj.product_id).to eq(15)
    end

    it 'returns null when order_product is invalid' do
      obj = OrderProduct.new(order: 12, product: 'as')
      expect(obj.id).to be_nil
      expect(obj).to be_invalid
      expect(obj.order_id).to eq(12)

      obj = OrderProduct.new(order: 'a', product: 15)
      expect(obj.id).to be_nil
      expect(obj).to be_invalid
      expect(obj.product_id).to eq(15)
    end
  end

  describe '#order' do
    it 'fetches the Order' do
      Order.create(id: 12)

      obj = OrderProduct.new(order: 12, product: 15)

      expect(obj.id).to eq('1215')
      expect(obj.order_id).to eq(12)

      expect(obj.order).to_not be_nil
      expect(obj.order.id).to eq(12)
    end

    it 'returns nil when the Order does not exist' do
      obj = OrderProduct.new(order: 120, product: 15)

      expect(obj.id).to eq('12015')
      expect(obj.order_id).to eq(120)

      expect(obj.order).to be_nil
    end

    it 'is lazy and will fetch the Order only when needed' do
      obj = OrderProduct.new(order: 125, product: 15)

      expect(obj.id).to eq('12515')
      expect(obj.order_id).to eq(125)

      expect(obj.order).to be_nil

      Order.create(id: 125)

      expect(obj.order).to_not be_nil
      expect(obj.order.id).to eq(125)
    end
  end

  describe '#product' do
    it 'fetches the Product' do
      Product.create(id: 15, value: 25.5)

      obj = OrderProduct.new(order: 12, product: 15)

      expect(obj.id).to eq('1215')
      expect(obj.product_id).to eq(15)

      expect(obj.product).to_not be_nil
      expect(obj.product.id).to eq(15)
      expect(obj.product.value).to eq(25.5)
    end

    it 'returns nil when the Product does not exist' do
      obj = OrderProduct.new(order: 120, product: 150)

      expect(obj.id).to eq('120150')
      expect(obj.product_id).to eq(150)

      expect(obj.product).to be_nil
    end

    it 'is lazy and will fetch the Product only when needed' do
      obj = OrderProduct.new(order: 125, product: 155)

      expect(obj.id).to eq('125155')
      expect(obj.product_id).to eq(155)

      expect(obj.product).to be_nil

      Product.create(id: 155, value: 35_888)

      expect(obj.product).to_not be_nil
      expect(obj.product.id).to eq(155)
      expect(obj.product.value).to eq(35_888)
    end
  end
end
