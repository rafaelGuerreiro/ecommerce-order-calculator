describe CsvModel::FieldDefinition::Argument do
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
end
