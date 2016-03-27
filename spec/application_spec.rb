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
  end

  describe '#load_models' do
  end

  describe '#serialize_result' do
  end

  private

  def expand_path(file_path)
    File.expand_path(File.join('..', '..', file_path), __FILE__)
  end
end
