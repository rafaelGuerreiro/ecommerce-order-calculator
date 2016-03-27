describe CsvFile do
  before do
    stub_const 'Foo', Class.new(CsvModel::Base)
  end

  describe '.new' do
    it 'allows file path without extension' do
      file = CsvFile.new(Foo, 'file_name')
      expect(file.file_path).to eq('file_name.csv')
    end

    it 'allows file path with csv extension' do
      file = CsvFile.new(Foo, 'other file.csv')
      expect(file.file_path).to eq('other file.csv')
    end

    it 'allows relative file path no matter if there is extension or not' do
      file = CsvFile.new(Foo, '../folder/a.file.csv')
      expect(file.file_path).to eq('../folder/a.file.csv')

      file = CsvFile.new(Foo, '../folder/another.file')
      expect(file.file_path).to eq('../folder/another.file.csv')
    end

    it 'allows trailing spaces in the file path no matter ' \
    'if there is extension or not' do
      file = CsvFile.new(Foo, ' ../folder/a.file.csv   ')
      expect(file.file_path).to eq('../folder/a.file.csv')

      file = CsvFile.new(Foo, ' ../folder/another.file   ')
      expect(file.file_path).to eq('../folder/another.file.csv')
    end

    it 'cannot modify the original string' do
      file_path = 'the_file'
      file = CsvFile.new Foo, file_path

      expect(file_path).to eq('the_file')
      expect(file.file_path).to eq('the_file.csv')
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
      file = CsvFile.new(Foo, '../folder/a.file.csv')

      expect { file.file_path << 'teste' }
        .to raise_error(RuntimeError, "can't modify frozen String")
    end
  end

  describe '#path' do
    it 'returns the file enclosing folder' do
      file = CsvFile.new(Foo, '../folder/a.file.csv')
      expect(file.path).to eq('../folder')
    end

    it 'returns nil when the file is invalid' do
      file = CsvFile.new(nil, '../folder/a.file.csv')

      expect(file).to be_invalid
      expect(file.path).to be_nil
    end

    it 'replaces backslashes to slashes' do
      file = CsvFile.new(Foo, '..\\folder\\a.file.csv')
      expect(file.path).to eq('../folder')
    end
  end

  describe '#valid?' do
    it 'returns true when the model class and the file path is present' do
      file = CsvFile.new(Foo, ' ../folder/a.file.csv   ')
      expect(file).to be_valid

      file = CsvFile.new(Foo, ' ../folder/a.file   ')
      expect(file).to be_valid
    end

    it 'returns false when the file path is not present' do
      file = CsvFile.new(Foo, nil)
      expect(file).to_not be_valid

      file = CsvFile.new(Foo, '')
      expect(file).to_not be_valid

      file = CsvFile.new(Foo, '    ')
      expect(file).to_not be_valid

      file = CsvFile.new(Foo, "  \n  ")
      expect(file).to_not be_valid
    end

    it 'returns false when class does not extend CsvModel::Base' do
      file = CsvFile.new(nil, '../folder/csv_file')
      expect(file).to_not be_valid

      file = CsvFile.new(String, '../folder/csv_file')
      expect(file).to_not be_valid

      file = CsvFile.new(CsvModel::Base, '../folder/csv_file')
      expect(file).to_not be_valid
    end
  end

  describe '#invalid?' do
    it 'returns false when the file path is present' do
      file = CsvFile.new(Foo, ' ../folder/a.file.csv   ')
      expect(file).to_not be_invalid

      file = CsvFile.new(Foo, ' ../folder/a.file   ')
      expect(file).to_not be_invalid
    end

    it 'returns true when the file path is not present' do
      file = CsvFile.new(Foo, nil)
      expect(file).to be_invalid

      file = CsvFile.new(Foo, '')
      expect(file).to be_invalid

      file = CsvFile.new(Foo, '    ')
      expect(file).to be_invalid
    end
  end
end
