describe CsvModel::FieldDefinition::Enum do
  before do
    stub_const 'Foo', Class.new
  end

  describe '#to_enumeration_checks' do
    it 'defines check methods to verify the enum' do
      field = CsvModel::FieldDefinition::Field.new Foo, :type,
                                                   enum: [:absolute, :percent]
      expect(field.to_enumeration_checks).to eq(%(
            def absolute?
              @type == :absolute
            end
            def percent?
              @type == :percent
            end)
                                                )
    end

    it 'returns empty when field is not an enum' do
      field = CsvModel::FieldDefinition::Field.new Foo, :type
      expect(field.to_enumeration_checks).to eq('')
    end
  end
end
