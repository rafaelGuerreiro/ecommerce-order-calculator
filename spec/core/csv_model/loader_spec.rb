describe CsvModel::Loader do
  before do
    stub_const 'Foo', Class.new(CsvModel::Base)

    Foo.class_eval do
      define_id_field
      define_field :name
      define_field :price, type: :numeric
    end
  end

  describe '.load' do
    it 'loads the csv, instantiates all models and persists them' do
      csv_data = [
        '1,Foo,12', '2,,30', '',
        '1,Wrong,15', '2,Bar,15.5',
        ',,', '', ''
      ]
      file_path = 'all_foos.csv'
      stub_csv_file file_path, csv_data.join("\n")

      foos = Foo.load(file_path)

      expect(foos).to have(2).records

      expect(Foo.find(1)).to be(foos[0])
      expect(Foo.find(2)).to be(foos[1])

      expect(foos[0].name).to eq('Foo')
      expect(foos[1].name).to eq('Bar')

      expect(foos[0].price).to eq(12)
      expect(foos[1].price).to eq(15.5)
    end
  end

  describe '.find' do
    before do
      csv_data = [
        '1,Foo,12', '2,,30', '',
        '1,Wrong,15', '2,Bar,15.5',
        ',,', '', ''
      ]
      file_path = 'all_foos.csv'
      stub_csv_file file_path, csv_data.join("\n")

      Foo.load(file_path)
    end

    it 'returns nil when id is not persisted' do
      expect(Foo.find(2)).to_not be_nil
      expect(Foo.find(3)).to be_nil
    end

    it 'returns the correct record when it is in the repository' do
      foo = Foo.find(1)
      expect(foo).to_not be_nil
      expect(foo.name).to eq('Foo')
    end
  end

  describe '.find_by' do
    before do
      csv_data = [
        '1,Foo,12', '2,,30', '',
        '1,Wrong,15', '2,Bar,15.5',
        ',,', '', ''
      ]
      file_path = 'all_foos.csv'
      stub_csv_file file_path, csv_data.join("\n")

      Foo.load(file_path)
    end

    it 'fetches by attribute' do
      expect(Foo.find_by(id: 2)).to have(1).element
      expect(Foo.find_by(name: 'Bar', id: 2)).to have(1).element
      expect(Foo.find_by(name: 'Wrong')).to eq([])
    end
  end

  describe '.find_by_attribute' do
    before do
      csv_data = [
        '1,Foo,12', '2,,30', '',
        '1,Wrong,15', '2,Bar,15.5',
        ',,', '', ''
      ]
      file_path = 'all_foos.csv'
      stub_csv_file file_path, csv_data.join("\n")

      Foo.load(file_path)
    end

    it 'fetches by single attribute' do
      expect(Foo.find_by_id(2)).to have(1).element
      expect(Foo.find_by_name('Bar')).to have(1).element
      expect(Foo.find_by_name('Wrong')).to eq([])
    end

    it 'fetches by multi attributes' do
      expect(Foo.find_by_id_and_name(2, 'Bar')).to have(1).element
      expect(Foo.find_by_name_and_price('Bar', 15.5)).to have(1).element
      expect(Foo.find_by_name_and_id('Wrong', 2)).to eq([])
    end

    it 'responds to the find_by_attribute methods' do
      expect(Foo.respond_to?(:find_by_id)).to be_truthy
      expect(Foo.respond_to?(:find_by_price)).to be_truthy
      expect(Foo.respond_to?(:find_by_name)).to be_truthy
      expect(Foo.respond_to?(:find_by_attribute))
        .to be_truthy

      expect(Foo.respond_to?(:find_by_id_and_name)).to be_truthy
      expect(Foo.respond_to?(:find_by_name_and_price)).to be_truthy
      expect(Foo.respond_to?(:find_by_name_and_id)).to be_truthy
      expect(Foo.respond_to?(:find_by_attribute_and_another_attribute))
        .to be_truthy
    end

    it "delegates to super when the method doesn't start with 'find_by'" do
      expect(Foo.respond_to?(:find_id)).to be_falsy
      expect(Foo.respond_to?(:find_bu_name_and_price)).to be_falsy
      expect(Foo.respond_to?(:by_name_and_id)).to be_falsy
      expect(Foo.respond_to?(:unknown_attribute)).to be_falsy

      expect { Foo.find_id(2) }.to raise_error(NoMethodError)
      expect { Foo.find_bu_name_and_price('Bar', 15.5) }
        .to raise_error(NoMethodError)
      expect { Foo.by_name_and_id('Bar', 2) }.to raise_error(NoMethodError)
      expect { Foo.unknown_attribute }.to raise_error(NoMethodError)
    end
  end
end
