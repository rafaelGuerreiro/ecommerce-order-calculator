describe CsvModel::FieldDefinition::Field do
  before do
    stub_const 'Foo', Class.new
  end

  describe '#options' do
    it 'is frozen' do
      field = CsvModel::FieldDefinition::Field.new Foo, :name, presence: false
      expect { field.options[:presence] = true }
        .to raise_error(RuntimeError, "can't modify frozen Hash")
    end

    it 'has presence: true and type: :string as default' do
      field = CsvModel::FieldDefinition::Field.new Foo, :name

      expect(field.options[:presence]).to be_truthy
      expect(field.options[:type]).to be(:string)

      expect(field.options.keys).to have(2).keys
      expect(field.options.keys).to include(:presence, :type)
    end

    it 'deletes unknown keys, keeping known ones' do
      field = CsvModel::FieldDefinition::Field.new Foo, :name,
                                                   presence: false,
                                                   test: 'not ok'

      expect(field.options.key?(:test)).to be_falsy

      expect(field.options[:presence]).to be_falsy
      expect(field.options[:type]).to be(:string)

      expect(field.options.keys).to have(2).keys
      expect(field.options.keys).to include(:presence, :type)
    end

    it 'does not set the pattern when type is :numeric' do
      field = CsvModel::FieldDefinition::Field.new Foo, :age, type: :numeric

      expect(field.options[:type]).to be(:numeric)
      expect(field.options[:pattern]).to be_nil

      expect(field.options.keys).to have(2).keys
      expect(field.options.keys).to include(:presence, :type)
    end

    it 'does not set the pattern when type is :date' do
      field = CsvModel::FieldDefinition::Field.new Foo, :birthday, type: :date

      expect(field.options[:type]).to be(:date)
      expect(field.options[:pattern]).to be_nil

      expect(field.options.keys).to have(2).keys
      expect(field.options.keys).to include(:presence, :type)
    end

    it 'sets the pattern when an enum is defined' do
      field = CsvModel::FieldDefinition::Field.new Foo, :discount_type,
                                                   enum: [:absolute, :percent]

      expect(field.options[:type]).to be(:enum)
      expect(field.options[:pattern]).to_not be_nil

      expect(field.options.keys).to have(4).keys
      expect(field.options.keys)
        .to include(:presence, :type, :pattern, :enum)
    end
  end

  describe '#valid?' do
    it 'is valid when class is a class and name is a symbol' do
      field = CsvModel::FieldDefinition::Field.new Foo, nil
      expect(field).to_not be_valid

      field = CsvModel::FieldDefinition::Field.new Foo, 'attribute'
      expect(field).to_not be_valid

      field = CsvModel::FieldDefinition::Field.new Foo, :attribute
      expect(field).to be_valid
    end
  end

  describe '#invalid?' do
    it 'is invalid when class is not a class or name is not a symbol' do
      field = CsvModel::FieldDefinition::Field.new Foo, nil
      expect(field).to be_invalid

      field = CsvModel::FieldDefinition::Field.new Foo, 'attribute'
      expect(field).to be_invalid

      field = CsvModel::FieldDefinition::Field.new Foo, :attribute
      expect(field).to_not be_invalid
    end
  end

  describe '#to_attr_reader' do
    it 'delegates to attr_reader' do
      field = CsvModel::FieldDefinition::Field.new Foo, :attribute_xpto,
                                                   type: :numeric
      expect(field.to_attr_reader).to eq('attr_reader :attribute_xpto')
    end

    it 'delegates to attr_reader even when it is a date field' do
      field = CsvModel::FieldDefinition::Field.new Foo, :birthday, type: :date
      expect(field.to_attr_reader).to eq('attr_reader :birthday')
    end
  end

  describe '#hash' do
    it 'is the same for different instances with different options ' \
      'but same class and same field name' do
      field1 = CsvModel::FieldDefinition::Field.new Foo, :id,
                                                    pattern: /\A[0-9]+\z/
      field2 = CsvModel::FieldDefinition::Field.new Foo, :id, presence: false

      expect(field1).not_to be(field2)
      expect(field1.hash).to eq(field2.hash)
    end

    it 'is different for different classes and same field name' do
      field1 = CsvModel::FieldDefinition::Field.new String, :id
      field2 = CsvModel::FieldDefinition::Field.new Foo, :id

      expect(field1).not_to be(field2)
      expect(field1.hash).not_to eq(field2.hash)
    end

    it 'is different for different field name and same class' do
      field1 = CsvModel::FieldDefinition::Field.new Foo, :id
      field2 = CsvModel::FieldDefinition::Field.new Foo, :name

      expect(field1).not_to be(field2)
      expect(field1.hash).not_to eq(field2.hash)
    end
  end

  describe '#==' do
    it 'is the same for different instances with different options ' \
      'but same class and same field name' do
      field1 = CsvModel::FieldDefinition::Field.new Foo, :id,
                                                    pattern: /\A[0-9]+\z/
      field2 = CsvModel::FieldDefinition::Field.new Foo, :id, presence: false

      expect(field1).not_to be(field2)
      expect(field1).to eq(field2)
    end

    it 'is different for different classes and same field name' do
      field1 = CsvModel::FieldDefinition::Field.new String, :id
      field2 = CsvModel::FieldDefinition::Field.new Foo, :id

      expect(field1).not_to be(field2)
      expect(field1).not_to eq(field2)
    end

    it 'is different for different field name and same class' do
      field1 = CsvModel::FieldDefinition::Field.new Foo, :id
      field2 = CsvModel::FieldDefinition::Field.new Foo, :name

      expect(field1).not_to be(field2)
      expect(field1).not_to eq(field2)
    end

    it 'is equals to Strings with the same name of the field' do
      field = CsvModel::FieldDefinition::Field.new Foo, :id

      expect(field).not_to be('id')
      expect(field).to eq('id')
      expect(field).to eq(:id)
    end
  end

  describe '#eql?' do
    it 'is the same for different instances with different options ' \
      'but same class and same field name' do
      field1 = CsvModel::FieldDefinition::Field.new Foo, :id,
                                                    pattern: /\A[0-9]+\z/
      field2 = CsvModel::FieldDefinition::Field.new Foo, :id, presence: false

      expect(field1).not_to be(field2)
      expect(field1).to eql(field2)
    end

    it 'is different for different classes and same field name' do
      field1 = CsvModel::FieldDefinition::Field.new String, :id
      field2 = CsvModel::FieldDefinition::Field.new Foo, :id

      expect(field1).not_to be(field2)
      expect(field1).not_to eql(field2)
    end

    it 'is different for different field name and same class' do
      field1 = CsvModel::FieldDefinition::Field.new Foo, :id
      field2 = CsvModel::FieldDefinition::Field.new Foo, :name

      expect(field1).not_to be(field2)
      expect(field1).not_to eql(field2)
    end

    it 'returns false for Strings with the same name of the field' do
      field = CsvModel::FieldDefinition::Field.new Foo, :id

      expect(field).not_to be('id')
      expect(field).to eq('id')
      expect(field).to eq(:id)
      expect(field).not_to eql('id')
      expect(field).not_to eql(:id)
    end
  end
end
