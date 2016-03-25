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
      csv_data = "1,Foo,12\n2,,30\n\n1,Wrong,15\n2,Bar,15.5\n,,\n\n"
      file_path = 'all_foos.csv'
      stub_csv_file file_path, csv_data

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
      csv_data = "1,Foo,12\n2,,30\n\n1,Wrong,15\n2,Bar,15.5\n,,\n\n"
      file_path = 'all_foos.csv'
      stub_csv_file file_path, csv_data

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
end
