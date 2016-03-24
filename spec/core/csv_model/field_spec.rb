describe CsvModel::Field do
  before do
    stub_const 'Foo', Class.new
  end

  describe '#to_argument' do
    it 'returns a required argument name when there is no default value' do
      field = CsvModel::Field.new Foo, :name
      expect(field.to_argument).to eq('name:')
    end

    it 'returns an argument with a value when there is default value' do
      field = CsvModel::Field.new Foo, :is_abc, default: true
      expect(field.to_argument).to eq('is_abc: true')
    end

    it 'returns an optional argument when default value is defined as nil' do
      field = CsvModel::Field.new Foo, :an_attribute, default: nil
      expect(field.to_argument).to eq('an_attribute: nil')
    end

    it 'returns nil when field is invalid' do
      field = CsvModel::Field.new nil, :attribute_xpto
      expect(field.to_argument).to be_nil

      field = CsvModel::Field.new Foo, 'attribute_xpto'
      expect(field.to_argument).to be_nil
    end
  end

  describe '#to_assignment' do
    it 'assigns the argument to its attribute' do
      field = CsvModel::Field.new Foo, :name
      expect(field.to_assignment).to eq('@name = name')
    end

    it 'returns nil when field is invalid' do
      field = CsvModel::Field.new nil, :attribute_xpto
      expect(field.to_assignment).to be_nil

      field = CsvModel::Field.new Foo, 'attribute_xpto'
      expect(field.to_assignment).to be_nil
    end
  end

  describe '#options' do
    it 'is frozen' do
      field = CsvModel::Field.new Foo, :name, presence: false
      expect { field.options[:presence] = true }
        .to raise_error(RuntimeError, "can't modify frozen Hash")
    end

    it 'has presence: true and type: :string as default' do
      field = CsvModel::Field.new Foo, :name

      expect(field.options[:presence]).to be_truthy
      expect(field.options[:type]).to be(:string)

      expect(field.options.keys).to have(2).keys
      expect(field.options.keys).to include(:presence, :type)
    end
  end

  describe '#valid?' do
    it 'is valid when class is a class and name is a symbol' do
      field = CsvModel::Field.new Foo, nil
      expect(field.valid?).to be_falsy

      field = CsvModel::Field.new Foo, 'attribute'
      expect(field.valid?).to be_falsy

      field = CsvModel::Field.new Foo, :attribute
      expect(field.valid?).to be_truthy
    end
  end

  describe '#invalid?' do
    it 'is invalid when class is not a class or name is not a symbol' do
      field = CsvModel::Field.new Foo, nil
      expect(field.invalid?).to be_truthy

      field = CsvModel::Field.new Foo, 'attribute'
      expect(field.invalid?).to be_truthy

      field = CsvModel::Field.new Foo, :attribute
      expect(field.invalid?).to be_falsy
    end
  end

  describe '#to_validity' do
    it 'checks presence by default' do
      field = CsvModel::Field.new Foo, :attribute_xpto
      expect(field.to_validity)
        .to eq("\nresult = @attribute_xpto.present? if result")
    end

    it 'checks nothing when presence is falsy' do
      field = CsvModel::Field.new Foo, :attribute_xpto, presence: false
      expect(field.to_validity).to eq('')
    end

    it "checks the pattern when there's no presence but a pattern defined" do
      field = CsvModel::Field.new Foo, :id,
                                  presence: false,
                                  pattern: /\A[0-9]+\z/

      expect(field.to_validity)
        .to eq("\nresult = Regexp.new(\"(?-mix:\\A[0-9]+\\z)\")" \
          '.match(@id) if result && @id')
    end

    it 'checks both pattern and presence when presence is true ' \
      'and the pattern is set' do
      field = CsvModel::Field.new Foo, :id, pattern: /\A[0-9]+\z/

      expect(field.to_validity)
        .to eq("\nresult = @id.present? if result" \
          "\nresult = Regexp.new(\"(?-mix:\\A[0-9]+\\z)\")" \
          '.match(@id) if result && @id')
    end

    it 'returns nil when field is invalid' do
      field = CsvModel::Field.new nil, :attribute_xpto
      expect(field.to_validity).to be_nil

      field = CsvModel::Field.new Foo, 'attribute_xpto'
      expect(field.to_validity).to be_nil
    end
  end

  describe '#options' do
  end

  describe '#hash' do
    it 'is the same for different instances with different options ' \
      'but same class and same field name' do
      field1 = CsvModel::Field.new Foo, :id, pattern: /\A[0-9]+\z/
      field2 = CsvModel::Field.new Foo, :id, presence: false

      expect(field1).not_to be(field2)
      expect(field1.hash).to eq(field2.hash)
    end

    it 'is different for different classes and same field name' do
      field1 = CsvModel::Field.new String, :id
      field2 = CsvModel::Field.new Foo, :id

      expect(field1).not_to be(field2)
      expect(field1.hash).not_to eq(field2.hash)
    end

    it 'is different for different field name and same class' do
      field1 = CsvModel::Field.new Foo, :id
      field2 = CsvModel::Field.new Foo, :name

      expect(field1).not_to be(field2)
      expect(field1.hash).not_to eq(field2.hash)
    end
  end

  describe '#==' do
    it 'is the same for different instances with different options ' \
      'but same class and same field name' do
      field1 = CsvModel::Field.new Foo, :id, pattern: /\A[0-9]+\z/
      field2 = CsvModel::Field.new Foo, :id, presence: false

      expect(field1).not_to be(field2)
      expect(field1).to eq(field2)
    end

    it 'is different for different classes and same field name' do
      field1 = CsvModel::Field.new String, :id
      field2 = CsvModel::Field.new Foo, :id

      expect(field1).not_to be(field2)
      expect(field1).not_to eq(field2)
    end

    it 'is different for different field name and same class' do
      field1 = CsvModel::Field.new Foo, :id
      field2 = CsvModel::Field.new Foo, :name

      expect(field1).not_to be(field2)
      expect(field1).not_to eq(field2)
    end

    it 'is equals to Strings with the same name of the field' do
      field = CsvModel::Field.new Foo, :id

      expect(field).not_to be('id')
      expect(field).to eq('id')
      expect(field).to eq(:id)
    end
  end

  describe '#eql?' do
    it 'is the same for different instances with different options ' \
      'but same class and same field name' do
      field1 = CsvModel::Field.new Foo, :id, pattern: /\A[0-9]+\z/
      field2 = CsvModel::Field.new Foo, :id, presence: false

      expect(field1).not_to be(field2)
      expect(field1).to eql(field2)
    end

    it 'is different for different classes and same field name' do
      field1 = CsvModel::Field.new String, :id
      field2 = CsvModel::Field.new Foo, :id

      expect(field1).not_to be(field2)
      expect(field1).not_to eql(field2)
    end

    it 'is different for different field name and same class' do
      field1 = CsvModel::Field.new Foo, :id
      field2 = CsvModel::Field.new Foo, :name

      expect(field1).not_to be(field2)
      expect(field1).not_to eql(field2)
    end

    it 'returns false for Strings with the same name of the field' do
      field = CsvModel::Field.new Foo, :id

      expect(field).not_to be('id')
      expect(field).to eq('id')
      expect(field).to eq(:id)
      expect(field).not_to eql('id')
      expect(field).not_to eql(:id)
    end
  end
end
