describe Order, :integration do
  before do
    CsvModelRepository.destroy!

    csvs = [{
      model: Order,
      file_path: 'orders'
    }, {
      model: Coupon,
      file_path: 'coupons'
    }, {
      model: OrderProduct,
      file_path: 'order_items'
    }, {
      model: Product,
      file_path: 'products'
    }]

    csvs.each do |csv|
      path = File.join('..', 'csvs', csv[:file_path])
      path = File.expand_path(path, __FILE__)

      csv[:model].load(path)
    end
  end

  describe '#products' do
    it 'fetches all products based on OrderProduct model' do
      order = Order.find(123)
      expect(order.products).to have(2).products
    end
  end
end
