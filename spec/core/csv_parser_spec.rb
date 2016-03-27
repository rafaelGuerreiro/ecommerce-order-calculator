describe CsvParser do
  before do
    stub_const 'Foo', Class.new(CsvModel::Base)
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

    it 'successfully parses when model has a string field' do
      csv_data = [
        '1,a name,an ignored field',
        '2,another name,',
        ',,',
        '0, , ',
        ''
      ]
      file_path = 'a_csv_file.csv'

      stub_csv_file(file_path: file_path, csv_data: csv_data)

      Foo.class_eval do
        define_id_field
        define_field :name
      end

      models = CsvParser.new(Foo, file_path).parse_csv

      expect(models).to have(5).objects

      valid = models.select(&:valid?)
      invalid = models.select(&:invalid?)

      expect(valid.map(&:name)).to contain_exactly('a name', 'another name')
      expect(valid.count).to eq(2)

      expect(invalid.map(&:name)).to contain_exactly(nil, ' ', nil)
      expect(invalid.count).to eq(3)
    end

    it 'successfully parses when model has id and a date field' do
      csv_data = [
        'a name,a field',
        '1,',
        ',',
        ' , ',
        '',
        '2,2015/12/25',
        '3,2000/13/12',
        '',
        ''
      ]
      file_path = 'another_csv_file.csv'

      stub_csv_file(file_path: file_path, csv_data: csv_data)

      Foo.class_eval do
        define_id_field
        define_field :issued_at, type: :date
      end

      models = CsvParser.new(Foo, file_path).parse_csv

      expect(models).to have(9).objects

      valid = models.select(&:valid?)
      invalid = models.select(&:invalid?)

      expect(valid[0].id).to eq(2)
      expect(valid[0].issued_at).to eq(Date.new(2015, 12, 25))
      expect(valid.count).to eq(1)

      expect(invalid.map(&:id).uniq).to contain_exactly(1, nil, 3)
      expect(invalid.map(&:issued_at).uniq).to contain_exactly(nil)
      expect(invalid.count).to eq(8)
    end
  end
end
