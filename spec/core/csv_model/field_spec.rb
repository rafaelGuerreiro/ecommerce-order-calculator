describe CsvModel::FieldDefinition::Field do
  before do
    stub_const 'Foo', Class.new
  end

  describe '#to_argument' do
    it "returns an optional argument name even when there's no default value" do
      field = CsvModel::FieldDefinition::Field.new Foo, :name
      expect(field.to_argument).to eq('name: nil')
    end

    it 'returns an argument with a value when there is default value' do
      field = CsvModel::FieldDefinition::Field.new Foo, :is_abc, default: true
      expect(field.to_argument).to eq('is_abc: true')
    end

    it 'returns an argument when default value is defined as nil' do
      field = CsvModel::FieldDefinition::Field.new Foo, :an_attribute,
                                                   default: nil
      expect(field.to_argument).to eq('an_attribute: nil')
    end

    it 'returns an argument when default value is defined as "test"' do
      field = CsvModel::FieldDefinition::Field.new Foo, :an_attribute,
                                                   default: 'test'
      expect(field.to_argument).to eq('an_attribute: "test"')
    end

    it 'returns an argument when default value is defined as an array' do
      field = CsvModel::FieldDefinition::Field.new Foo, :an_attribute,
                                                   default: ['test', 123]
      expect(field.to_argument).to eq('an_attribute: ["test", 123]')
    end

    it 'returns an optional argument when default value is not defined '\
      'but it is not required' do
      field = CsvModel::FieldDefinition::Field.new Foo, :an_attribute,
                                                   presence: false
      expect(field.to_argument).to eq('an_attribute: nil')
    end

    it 'returns nil when field is invalid' do
      field = CsvModel::FieldDefinition::Field.new nil, :attribute_xpto
      expect(field.to_argument).to be_nil

      field = CsvModel::FieldDefinition::Field.new Foo, 'attribute_xpto'
      expect(field.to_argument).to be_nil
    end
  end

  describe '#to_assignment' do
    it 'assigns the argument to its attribute' do
      field = CsvModel::FieldDefinition::Field.new Foo, :name
      expect(field.to_assignment).to eq('@name = name')
    end

    it 'returns nil when field is invalid' do
      field = CsvModel::FieldDefinition::Field.new nil, :attribute_xpto
      expect(field.to_assignment).to be_nil

      field = CsvModel::FieldDefinition::Field.new Foo, 'attribute_xpto'
      expect(field.to_assignment).to be_nil
    end

    it 'converts to date when type is :date' do
      field = CsvModel::FieldDefinition::Field.new Foo, :dt, type: :date
      expect(field.to_assignment).to eq(%(
          begin
            if dt.is_a?(String)
              dt = Date.strptime(dt, '%Y/%m/%d')
            end
          rescue ArgumentError
            dt = nil
          end
          @dt = dt)
                                       )
    end

    it 'converts to number when type is :numeric' do
      field = CsvModel::FieldDefinition::Field.new Foo, :id, type: :numeric
      expect(field.to_assignment).to eq(%(
          begin
            if id.is_a?(String)
              if id.include?('.')
                id = Float(id)
              else
                id = Integer(id)
              end
            end
          rescue ArgumentError
            id = nil
          end
          @id = id)
                                       )
    end
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
      expect(field.valid?).to be_falsy

      field = CsvModel::FieldDefinition::Field.new Foo, 'attribute'
      expect(field.valid?).to be_falsy

      field = CsvModel::FieldDefinition::Field.new Foo, :attribute
      expect(field.valid?).to be_truthy
    end
  end

  describe '#invalid?' do
    it 'is invalid when class is not a class or name is not a symbol' do
      field = CsvModel::FieldDefinition::Field.new Foo, nil
      expect(field.invalid?).to be_truthy

      field = CsvModel::FieldDefinition::Field.new Foo, 'attribute'
      expect(field.invalid?).to be_truthy

      field = CsvModel::FieldDefinition::Field.new Foo, :attribute
      expect(field.invalid?).to be_falsy
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

  describe '#validable?' do
    it 'returns true for default options' do
      field = CsvModel::FieldDefinition::Field.new Foo, :id
      expect(field.validable?).to be_truthy
    end

    it 'returns true when pattern is set' do
      field = CsvModel::FieldDefinition::Field.new Foo, :age,
                                                   pattern: /\d{,2}/,
                                                   presence: false
      expect(field.validable?).to be_truthy
    end

    it 'returns true when pattern and presence are set' do
      field = CsvModel::FieldDefinition::Field.new Foo, :age,
                                                   pattern: /\d{,2}/
      expect(field.validable?).to be_truthy
    end

    it "returns false when both pattern and presence aren't set" do
      field = CsvModel::FieldDefinition::Field.new Foo, :age,
                                                   presence: false
      expect(field.validable?).to be_falsy
    end

    it 'returns false when field is invalid' do
      field = CsvModel::FieldDefinition::Field.new Foo, 'age'
      expect(field.validable?).to be_falsy

      field = CsvModel::FieldDefinition::Field.new nil, :age
      expect(field.validable?).to be_falsy
    end
  end

  describe '#value_valid?' do
    it 'is truthy when it is validable and the value is present' do
      field = CsvModel::FieldDefinition::Field.new Foo, :name
      expect(field.value_valid?('Rafael Guerreiro')).to be_truthy
    end

    it 'is falsy when it is validable and the value is not present' do
      field = CsvModel::FieldDefinition::Field.new Foo, :name
      expect(field.value_valid?('   ')).to be_falsy
      expect(field.value_valid?('')).to be_falsy
      expect(field.value_valid?(nil)).to be_falsy
    end

    it 'is truthy when it is validable and the value follows the pattern' do
      field = CsvModel::FieldDefinition::Field.new Foo, :name,
                                                   pattern: /\Ael.*?ion\z/
      expect(field.value_valid?('electrification')).to be_truthy
      expect(field.value_valid?('elucidation')).to be_truthy
      expect(field.value_valid?('elision')).to be_truthy
      expect(field.value_valid?('eructation')).to be_falsy
      expect(field.value_valid?(nil)).to be_falsy
    end

    it "is truthy when the value has a pattern but it's empty" do
      field = CsvModel::FieldDefinition::Field.new Foo, :name,
                                                   pattern: /\Ael.*?ion\z/,
                                                   presence: false
      expect(field.value_valid?('electrification')).to be_truthy
      expect(field.value_valid?('elucidation')).to be_truthy
      expect(field.value_valid?('elision')).to be_truthy
      expect(field.value_valid?('eructation')).to be_falsy
      expect(field.value_valid?(nil)).to be_truthy
    end
  end
end
