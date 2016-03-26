describe CsvFile do
  before do
    stub_const 'Foo', Class.new(CsvModel::Base)
  end

  describe '.new' do
    it 'allows file path without extension' do
      parser = CsvFile.new(Foo, 'file_name')
      expect(parser.file_path).to eq('file_name.csv')
    end

    it 'allows file path with csv extension' do
      parser = CsvFile.new(Foo, 'other file.csv')
      expect(parser.file_path).to eq('other file.csv')
    end

    it 'allows relative file path no matter if there is extension or not' do
      parser = CsvFile.new(Foo, '../folder/a.file.csv')
      expect(parser.file_path).to eq('../folder/a.file.csv')

      parser = CsvFile.new(Foo, '../folder/another.file')
      expect(parser.file_path).to eq('../folder/another.file.csv')
    end

    it 'allows trailing spaces in the file path no matter ' \
    'if there is extension or not' do
      parser = CsvFile.new(Foo, ' ../folder/a.file.csv   ')
      expect(parser.file_path).to eq('../folder/a.file.csv')

      parser = CsvFile.new(Foo, ' ../folder/another.file   ')
      expect(parser.file_path).to eq('../folder/another.file.csv')
    end

    it 'cannot modify the original string' do
      file_path = 'the_file'
      parser = CsvFile.new Foo, file_path

      expect(file_path).to eq('the_file')
      expect(parser.file_path).to eq('the_file.csv')
    end

    it 'cannot have an empty or nil file path' do
      expect { CsvFile.new Foo, nil }.to_not raise_error
      expect { CsvFile.new Foo, '' }.to_not raise_error
      expect { CsvFile.new Foo, '  ' }.to_not raise_error

      expect { CsvFile.new nil, 'the_file' }.to_not raise_error
      expect { CsvFile.new String, 'the_file' }.to_not raise_error
    end
  end

  describe '#file_path' do
    it 'must be immutable' do
      parser = CsvFile.new(Foo, '../folder/a.file.csv')

      expect { parser.file_path << 'teste' }
        .to raise_error(RuntimeError, "can't modify frozen String")
    end
  end

  describe '#valid?' do
    it 'returns true when the model class and the file path is present' do
      parser = CsvFile.new(Foo, ' ../folder/a.file.csv   ')
      expect(parser.valid?).to be_truthy

      parser = CsvFile.new(Foo, ' ../folder/a.file   ')
      expect(parser.valid?).to be_truthy
    end

    it 'returns false when the file path is not present' do
      parser = CsvFile.new(Foo, nil)
      expect(parser.valid?).to be_falsy

      parser = CsvFile.new(Foo, '')
      expect(parser.valid?).to be_falsy

      parser = CsvFile.new(Foo, '    ')
      expect(parser.valid?).to be_falsy

      parser = CsvFile.new(Foo, "  \n  ")
      expect(parser.valid?).to be_falsy
    end

    it 'returns false when class does not extend CsvModel::Base' do
      parser = CsvFile.new(nil, '../folder/csv_file')
      expect(parser.valid?).to be_falsy

      parser = CsvFile.new(String, '../folder/csv_file')
      expect(parser.valid?).to be_falsy

      parser = CsvFile.new(CsvModel::Base, '../folder/csv_file')
      expect(parser.valid?).to be_falsy
    end
  end

  describe '#invalid?' do
    it 'returns false when the file path is present' do
      parser = CsvFile.new(Foo, ' ../folder/a.file.csv   ')
      expect(parser.invalid?).to be_falsy

      parser = CsvFile.new(Foo, ' ../folder/a.file   ')
      expect(parser.invalid?).to be_falsy
    end

    it 'returns true when the file path is not present' do
      parser = CsvFile.new(Foo, nil)
      expect(parser.invalid?).to be_truthy

      parser = CsvFile.new(Foo, '')
      expect(parser.invalid?).to be_truthy

      parser = CsvFile.new(Foo, '    ')
      expect(parser.invalid?).to be_truthy
    end
  end
end
