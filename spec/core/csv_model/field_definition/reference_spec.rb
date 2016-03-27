describe CsvModel::FieldDefinition::Reference do
  before do
    stub_const 'Foo', Class.new
    stub_const 'Bar', Class.new(CsvModel::Base)

    Bar.class_eval { define_id_field }
  end

  describe '#to_attr_reader' do
    it 'creates two getters, one for id and the other for model' do
      field = CsvModel::FieldDefinition::Field.new Foo, :bar,
                                                   references: Bar
      expect(field.to_attr_reader).to eq(%(
          def bar_id
            @bar
          end

          def bar
            @bar_instance ||= Bar.find(@bar)
          end)
                                        )
    end
  end
end
