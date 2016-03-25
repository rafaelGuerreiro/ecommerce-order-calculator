describe CsvModel::FieldDefinition::Validator do
  before do
    stub_const 'Foo', Class.new
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
      expect(field.value_valid?('elicitation')).to be_truthy
      expect(field.value_valid?('elimination')).to be_truthy
      expect(field.value_valid?('emaciation')).to be_falsy
      expect(field.value_valid?(nil)).to be_truthy
    end
  end
end
