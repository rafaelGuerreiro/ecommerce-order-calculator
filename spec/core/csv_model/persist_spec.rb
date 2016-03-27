describe CsvModel::Loader do
  before do
    CsvModelRepository.destroy!

    stub_const 'Product', Class.new(CsvModel::Base)

    Product.class_eval do
      define_id_field
      define_field :name
      define_field :price, type: :numeric
    end
  end

  describe '.create' do
    it 'instantiates a product object and persists it in CsvModelRepository' do
      expect(Product.find(123)).to be_nil

      product = Product.create(id: 123, name: 'a name', price: 125)
      expect(Product.find(123)).to be(product)
    end

    it 'allows multi object creation at a time' do
      expect(Product.find(123)).to be_nil
      expect(Product.find(234)).to be_nil
      expect(Product.find(345)).to be_nil
      expect(Product.find(456)).to be_nil

      products = Product.create(
        { id: 123, name: 'Chocolate', price: 10 },
        { id: 234, name: 'Water', price: 1 },
        { id: 345, name: 'Smartphone', price: 500 },
        { id: 456, name: 'Wallet', price: 30 }
      )

      expect(Product.find(123)).to be(products[0])
      expect(Product.find(234)).to be(products[1])
      expect(Product.find(345)).to be(products[2])
      expect(Product.find(456)).to be(products[3])
    end
  end

  describe '#save' do
    it 'persists product in CsvModelRepository' do
      product = Product.new(id: 123, name: 'a name', price: 125)

      expect(Product.find(123)).to be_nil

      product.save

      expect(Product.find(123)).to be(product)
    end
  end
end
