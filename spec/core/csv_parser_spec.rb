describe CsvParser, :model do
  before do
    stub_const 'Foo', Class.new(CsvModel::Base)
  end

  describe '.new' do
    it 'allows file path without extension' do
      csv = CsvParser.new(Foo, 'file_name')
      expect(csv.file_path).to eq('file_name.csv')
    end

    it 'allows file path with csv extension' do
      csv = CsvParser.new(Foo, 'other file.csv')
      expect(csv.file_path).to eq('other file.csv')
    end

    it 'allows relative file path no matter if there is extension or not' do
      csv = CsvParser.new(Foo, '../folder/a.file.csv')
      expect(csv.file_path).to eq('../folder/a.file.csv')

      csv = CsvParser.new(Foo, '../folder/another.file')
      expect(csv.file_path).to eq('../folder/another.file.csv')
    end

    it 'allows trailing spaces in the file path no matter ' \
    'if there is extension or not' do
      csv = CsvParser.new(Foo, ' ../folder/a.file.csv   ')
      expect(csv.file_path).to eq('../folder/a.file.csv')

      csv = CsvParser.new(Foo, ' ../folder/another.file   ')
      expect(csv.file_path).to eq('../folder/another.file.csv')
    end

    it 'cannot modify the original string' do
      file_path = 'the_file'
      csv = CsvParser.new Foo, file_path

      expect(file_path).to eq('the_file')
      expect(csv.file_path).to eq('the_file.csv')
    end

    it 'cannot have an empty or nil file path' do
      expect { CsvParser.new Foo, nil }.to_not raise_error
      expect { CsvParser.new Foo, '' }.to_not raise_error
      expect { CsvParser.new Foo, '  ' }.to_not raise_error

      expect { CsvParser.new nil, 'the_file' }.to_not raise_error
      expect { CsvParser.new String, 'the_file' }.to_not raise_error
    end
  end

  describe '#file_path' do
    it 'must be immutable' do
      csv = CsvParser.new(Foo, '../folder/a.file.csv')

      expect { csv.file_path << 'teste' }
        .to raise_error(RuntimeError, "can't modify frozen String")
    end
  end

  describe '#valid?' do
    it 'returns true when the model class and the file path is present' do
      csv = CsvParser.new(Foo, ' ../folder/a.file.csv   ')
      expect(csv.valid?).to be_truthy

      csv = CsvParser.new(Foo, ' ../folder/a.file   ')
      expect(csv.valid?).to be_truthy
    end

    it 'returns false when the file path is not present' do
      csv = CsvParser.new(Foo, nil)
      expect(csv.valid?).to be_falsy

      csv = CsvParser.new(Foo, '')
      expect(csv.valid?).to be_falsy

      csv = CsvParser.new(Foo, '    ')
      expect(csv.valid?).to be_falsy
    end

    it 'returns false when class does not extend CsvModel::Base' do
      csv = CsvParser.new(nil, '../folder/csv_file')
      expect(csv.valid?).to be_falsy

      csv = CsvParser.new(String, '../folder/csv_file')
      expect(csv.valid?).to be_falsy

      csv = CsvParser.new(CsvModel::Base, '../folder/csv_file')
      expect(csv.valid?).to be_falsy
    end
  end

  describe '#invalid?' do
    it 'returns false when the file path is present' do
      csv = CsvParser.new(Foo, ' ../folder/a.file.csv   ')
      expect(csv.invalid?).to be_falsy

      csv = CsvParser.new(Foo, ' ../folder/a.file   ')
      expect(csv.invalid?).to be_falsy
    end

    it 'returns true when the file path is not present' do
      csv = CsvParser.new(Foo, nil)
      expect(csv.invalid?).to be_truthy

      csv = CsvParser.new(Foo, '')
      expect(csv.invalid?).to be_truthy

      csv = CsvParser.new(Foo, '    ')
      expect(csv.invalid?).to be_truthy
    end
  end
end
