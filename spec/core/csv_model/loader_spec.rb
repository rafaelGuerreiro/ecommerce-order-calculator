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

  describe '.load' do
    it 'loads the csv, instantiates all models and persists them' do
      csv_data = [
        '1,Battery,12', '2,,30', '',
        '1,Wrong,15', '2,Board,15.5',
        ',,', '', ''
      ]
      file_path = 'all_products.csv'
      stub_csv_file file_path, csv_data

      products = Product.load(file_path)

      expect(products).to have(2).records

      expect(Product.find(1)).to be(products[0])
      expect(Product.find(2)).to be(products[1])

      expect(products[0].name).to eq('Battery')
      expect(products[1].name).to eq('Board')

      expect(products[0].price).to eq(12)
      expect(products[1].price).to eq(15.5)
    end
  end

  describe '.find' do
    before do
      csv_data = [
        '1,Battery,12', '2,,30', '',
        '1,Wrong,15', '2,Board,15.5',
        ',,', '', ''
      ]
      file_path = 'all_products.csv'
      stub_csv_file file_path, csv_data

      Product.load(file_path)
    end

    it 'returns nil when id is not persisted' do
      expect(Product.find(2)).to_not be_nil
      expect(Product.find(3)).to be_nil
    end

    it 'returns the correct record when it is in the repository' do
      product = Product.find(1)
      expect(product).to_not be_nil
      expect(product.name).to eq('Battery')
    end
  end

  describe '.find_by' do
    before do
      csv_data = [
        '1,Battery,12', '2,,30', '',
        '1,Wrong,15', '2,Board,15.5',
        ',,', '', ''
      ]
      file_path = 'all_products.csv'
      stub_csv_file file_path, csv_data

      Product.load(file_path)
    end

    it 'fetches by attribute' do
      expect(Product.find_by(id: 2)).to have(1).element
      expect(Product.find_by(name: 'Board', id: 2)).to have(1).element
      expect(Product.find_by(name: 'Wrong')).to eq([])
    end
  end

  describe '.find_by_attribute' do
    before do
      csv_data = [
        '1,Battery,12', '2,,30', '',
        '1,Wrong,15', '2,Board,15.5',
        ',,', '', ''
      ]
      file_path = 'all_products.csv'
      stub_csv_file file_path, csv_data

      Product.load(file_path)
    end

    it 'fetches by single attribute' do
      expect(Product.find_by_id(2)).to have(1).element
      expect(Product.find_by_name('Board')).to have(1).element
      expect(Product.find_by_name('Wrong')).to eq([])
    end

    it 'fetches by multi attributes' do
      expect(Product.find_by_id_and_name(2, 'Board')).to have(1).element
      expect(Product.find_by_name_and_price('Board', 15.5)).to have(1).element
      expect(Product.find_by_name_and_id('Wrong', 2)).to eq([])
    end

    it 'responds to the find_by_attribute methods' do
      expect(Product.respond_to?(:find_by_id)).to be_truthy
      expect(Product.respond_to?(:find_by_price)).to be_truthy
      expect(Product.respond_to?(:find_by_name)).to be_truthy
      expect(Product.respond_to?(:find_by_attribute))
        .to be_truthy

      expect(Product.respond_to?(:find_by_id_and_name)).to be_truthy
      expect(Product.respond_to?(:find_by_name_and_price)).to be_truthy
      expect(Product.respond_to?(:find_by_name_and_id)).to be_truthy
      expect(Product.respond_to?(:find_by_attribute_and_another_attribute))
        .to be_truthy
    end

    it "delegates to super when the method doesn't start with 'find_by'" do
      expect(Product.respond_to?(:find_id)).to be_falsy
      expect(Product.respond_to?(:find_bu_name_and_price)).to be_falsy
      expect(Product.respond_to?(:by_name_and_id)).to be_falsy
      expect(Product.respond_to?(:unknown_attribute)).to be_falsy

      expect { Product.find_id(2) }.to raise_error(NoMethodError)
      expect { Product.find_bu_name_and_price('Board', 15.5) }
        .to raise_error(NoMethodError)
      expect { Product.by_name_and_id('Board', 2) }
        .to raise_error(NoMethodError)
      expect { Product.unknown_attribute }.to raise_error(NoMethodError)
    end
  end

  describe '.all' do
    before do
      Product.create(
        { id: 4, name: 'Board', price: 15 },
        { id: 3, name: 'Apple', price: 2.49 },
        { id: 2, name: 'Battery', price: 12 },
        { id: 1, name: 'Chocolate', price: 9.99 }
      )
    end

    it 'returns all models from a class' do
      products = Product.all

      expect(products).to have(4).elements
    end

    it 'must be returned in the same order that they were inserted' do
      products = Product.all

      expect(products[0].id).to eq(4)
      expect(products[1].id).to eq(3)
      expect(products[2].id).to eq(2)
      expect(products[3].id).to eq(1)
    end
  end
end
