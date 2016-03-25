describe CsvModel::FieldDefinition::Assignment do
  before do
    stub_const 'Foo', Class.new
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

    it 'converts to symbol when type is :enum' do
      field = CsvModel::FieldDefinition::Field.new Foo, :type,
                                                   enum: [:absolute, :percent]
      expect(field.to_assignment).to eq(%(
          type = type.to_sym if type.is_a?(String)

          unless self.class.options(:type, :enum).include?(type)
            type = nil
          end
          @type = type)
                                       )
    end
  end
end
