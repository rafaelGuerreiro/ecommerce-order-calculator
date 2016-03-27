describe Application do
  describe '.new' do
    it 'merges the paths with the models and build a hash' do
      app = Application.new(
        [
          '/Users/coupons.csv',
          '/Users/products.csv',
          '/Users/orders.csv',
          '/Users/order_items.csv',
          '/Users/result.csv'
        ],
        [Coupon, Product, Order, OrderProduct, :result]
      )

      expect(app.files).to eq(
        Coupon => '/Users/coupons.csv',
        Product => '/Users/products.csv',
        Order => '/Users/orders.csv',
        OrderProduct => '/Users/order_items.csv',
        :result => '/Users/result.csv'
      )
    end

    it "automatically builds the full path when it's given a relative path" do
      app = Application.new(
        [
          'tmp/result.csv',
          'tmp/products.csv',
          '/Users/coupons.csv',
          'tmp/orders.csv',
          'tmp/items.csv'
        ],
        [:result, Product, Coupon, Order, OrderProduct]
      )

      expect(app.files).to eq(
        :result => expand_path('tmp/result.csv'),
        Product => expand_path('tmp/products.csv'),
        Coupon => '/Users/coupons.csv',
        Order => expand_path('tmp/orders.csv'),
        OrderProduct => expand_path('tmp/items.csv')
      )
    end

    it 'has a default model sort' do
      app = Application.new(
        [
          '/tmp/coupons.csv',
          '/tmp/products.csv',
          '/tmp/orders.csv',
          '/tmp/order_items.csv',
          '/tmp/result.csv'
        ]
      )

      expect(app.files).to eq(
        Coupon => '/tmp/coupons.csv',
        Product => '/tmp/products.csv',
        Order => '/tmp/orders.csv',
        OrderProduct => '/tmp/order_items.csv',
        :result => '/tmp/result.csv'
      )
    end

    it 'creates an empty fields when invalid value is passed ' \
      'for both arguments' do
      app = Application.new(nil, nil)
      expect(app.files.empty?).to be_truthy

      app = Application.new('not an array', 123)
      expect(app.files.empty?).to be_truthy
    end

    it 'validates the length of the paths with the models' do
      expect do
        Application.new(
          [
            '/tmp/coupons.csv',
            '/tmp/products.csv',
            '/tmp/orders.csv',
            '/tmp/order_items.csv'
          ]
        )
      end.to raise_error(ArgumentError, 'You have to provide 5 paths for the ' \
        "program be able to continue.\nThe order of models being used is: " \
        '[Coupon, Product, Order, OrderProduct, :result]')
    end
  end

  describe '#load_models' do
    it 'loads all CsvModel::Base it can find in the files hash' do
      products = [
        '123,150.0', '234,225.0', '345,250.0',
        '456,175.0', '567,100.0', '678,80.0',
        '789,2400.0', '890,75.0', '987,100.0',
        '876,120.0', ',', '123,', ',', ',', ','
      ]
      orders = [
        '123,', '234,123', '345,234',
        '456,345', '567,456', '678,567',
        '1000,567', '567,', ',123',
        ',', ' , ', ','
      ]

      stub_csv_file(
        { file_path: '/tmp/products.csv', csv_data: products },
        { file_path: '/tmp/orders.csv', csv_data: orders }
      )

      app = Application.new(
        ['/tmp/products.csv', '/tmp/orders.csv'],
        [Product, Order]
      )

      expect(Product.all).to be_empty
      expect(Order.all).to be_empty

      app.load_models do |clazz, file_path|
        expect(app.files.key?(clazz)).to be_truthy
        expect(app.files.value?(file_path)).to be_truthy
      end

      expect(Product.all).to have(10).products
      expect(Order.all).to have(7).orders
    end

    it "ignores anything that isn't subclass of CsvModel::Base" do
      app = Application.new(
        ['/a', '/b', '/c'],
        [String, :result, CsvModel::Base]
      )

      expect do
        app.load_models do |clazz, file_path|
          raise "This block shouldn't be invoked. " \
            "Class => #{clazz}, file_path => #{file_path}"
        end
      end.to_not raise_error
    end
  end

  private

  def expand_path(file_path)
    File.expand_path(File.join('..', '..', file_path), __FILE__)
  end
end
