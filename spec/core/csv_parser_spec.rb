describe CsvParser, :model do
  before do
    stub_const 'Foo', Class.new(CsvModel::Base)
  end

  describe '.new' do
    it 'allows file path without extension' do
      parser = CsvParser.new(Foo, 'file_name')
      expect(parser.file_path).to eq('file_name.csv')
    end

    it 'allows file path with csv extension' do
      parser = CsvParser.new(Foo, 'other file.csv')
      expect(parser.file_path).to eq('other file.csv')
    end

    it 'allows relative file path no matter if there is extension or not' do
      parser = CsvParser.new(Foo, '../folder/a.file.csv')
      expect(parser.file_path).to eq('../folder/a.file.csv')

      parser = CsvParser.new(Foo, '../folder/another.file')
      expect(parser.file_path).to eq('../folder/another.file.csv')
    end

    it 'allows trailing spaces in the file path no matter ' \
    'if there is extension or not' do
      parser = CsvParser.new(Foo, ' ../folder/a.file.csv   ')
      expect(parser.file_path).to eq('../folder/a.file.csv')

      parser = CsvParser.new(Foo, ' ../folder/another.file   ')
      expect(parser.file_path).to eq('../folder/another.file.csv')
    end

    it 'cannot modify the original string' do
      file_path = 'the_file'
      parser = CsvParser.new Foo, file_path

      expect(file_path).to eq('the_file')
      expect(parser.file_path).to eq('the_file.csv')
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
      parser = CsvParser.new(Foo, '../folder/a.file.csv')

      expect { parser.file_path << 'teste' }
        .to raise_error(RuntimeError, "can't modify frozen String")
    end
  end

  describe '#valid?' do
    it 'returns true when the model class and the file path is present' do
      parser = CsvParser.new(Foo, ' ../folder/a.file.csv   ')
      expect(parser.valid?).to be_truthy

      parser = CsvParser.new(Foo, ' ../folder/a.file   ')
      expect(parser.valid?).to be_truthy
    end

    it 'returns false when the file path is not present' do
      parser = CsvParser.new(Foo, nil)
      expect(parser.valid?).to be_falsy

      parser = CsvParser.new(Foo, '')
      expect(parser.valid?).to be_falsy

      parser = CsvParser.new(Foo, '    ')
      expect(parser.valid?).to be_falsy

      parser = CsvParser.new(Foo, "  \n  ")
      expect(parser.valid?).to be_falsy
    end

    it 'returns false when class does not extend CsvModel::Base' do
      parser = CsvParser.new(nil, '../folder/csv_file')
      expect(parser.valid?).to be_falsy

      parser = CsvParser.new(String, '../folder/csv_file')
      expect(parser.valid?).to be_falsy

      parser = CsvParser.new(CsvModel::Base, '../folder/csv_file')
      expect(parser.valid?).to be_falsy
    end
  end

  describe '#invalid?' do
    it 'returns false when the file path is present' do
      parser = CsvParser.new(Foo, ' ../folder/a.file.csv   ')
      expect(parser.invalid?).to be_falsy

      parser = CsvParser.new(Foo, ' ../folder/a.file   ')
      expect(parser.invalid?).to be_falsy
    end

    it 'returns true when the file path is not present' do
      parser = CsvParser.new(Foo, nil)
      expect(parser.invalid?).to be_truthy

      parser = CsvParser.new(Foo, '')
      expect(parser.invalid?).to be_truthy

      parser = CsvParser.new(Foo, '    ')
      expect(parser.invalid?).to be_truthy
    end
  end

  describe '#parse_csv' do
    it 'returns [] when CsvParser is invalid' do
      parser = CsvParser.new(Foo, nil)
      expect(parser.parse_csv).to eq([])

      parser = CsvParser.new(Foo, '   ')
      expect(parser.parse_csv).to eq([])

      parser = CsvParser.new(String, 'a_file.csv')
      expect(parser.parse_csv).to eq([])
    end

    it 'returns [] if the csv file does not exist' do
      Foo.class_eval { define_field :name }

      parser = CsvParser.new(Foo, 'non-existing-file')
      expect(parser.parse_csv).to eq([])
    end

    it 'returns [] if the model has no field' do
      parser = CsvParser.new(Foo, 'a_csv_file')
      expect(parser.parse_csv).to eq([])
    end

    it 'successfully parses when csv is in expected format' do
      csv_data = "a name,an ignored field\nanother name,\n,\n , \n"
      file_path = 'a_csv_file.csv'

      stub_file file_path, csv_data

      Foo.class_eval { define_field :name }

      models = CsvParser.new(Foo, file_path).parse_csv

      expect(models).to have(4).objects

      valid = models.select(&:valid?)
      invalid = models.select(&:invalid?)

      expect(valid.map(&:name)).to include('a name', 'another name')
      expect(valid.count).to eq(2)

      expect(invalid.map(&:name)).to include(nil, ' ')
      expect(invalid.count).to eq(2)
    end

    def stub_file(file_path, csv_data)
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:open)
        .with(file_path, universal_newline: false)
        .and_return(StringIO.new(csv_data))
    end
  end
end
