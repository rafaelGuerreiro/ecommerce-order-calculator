describe CsvModel::FieldDefinition do
  before do
    stub_const 'Foo', Class.new(CsvModel::Base)
  end

  describe '.define_field' do
    it 'defines one field with getter and add validity methods' do
      Foo.class_eval do
        define_id_field
        define_field :name
      end

      foo = Foo.new id: 1, name: 'Rafael Guerreiro'

      expect(foo.is_a?(CsvModel::Base)).to be_truthy

      expect(foo.id).to eq(1)
      expect(foo.name).to eq('Rafael Guerreiro')
      expect(foo).to be_valid
      expect(foo).to_not be_invalid
    end

    it 'defines various fields and append them to validity' do
      Foo.class_eval do
        define_id_field
        define_field :name
        define_field :age, type: :numeric
      end

      foo = Foo.new id: 120, name: 'Rafael Guerreiro', age: 23

      expect(foo.id).to eq(120)
      expect(foo.name).to eq('Rafael Guerreiro')
      expect(foo.age).to eq(23)
      expect(foo).to be_valid
      expect(foo).to_not be_invalid
    end

    it 'properly add validation for numeric fields' do
      Foo.class_eval do
        define_id_field
        define_field :number, type: :numeric
      end

      foo = Foo.new id: 1, number: 55
      expect(foo.number).to eq(55)
      expect(foo).to be_valid
      expect(foo).to_not be_invalid

      foo = Foo.new id: 1, number: 55.5
      expect(foo.number).to eq(55.5)
      expect(foo).to be_valid
      expect(foo).to_not be_invalid

      foo = Foo.new id: 1, number: '55.5'
      expect(foo.number).to eq(55.5)
      expect(foo).to be_valid
      expect(foo).to_not be_invalid

      foo = Foo.new id: 1, number: 'Rafael Guerreiro'
      expect(foo.number).to be_nil
      expect(foo).to_not be_valid
      expect(foo).to be_invalid
    end
  end

  describe '.define_fields' do
    it 'defines various fields with the same properties' do
      Foo.class_eval do
        define_id_field
        define_fields :name
        define_fields :age, :weight, :height, type: :numeric, presence: false
      end

      foo = Foo.new id: 1, name: 'Rafael Guerreiro'

      expect(foo.name).to eq('Rafael Guerreiro')
      expect(foo.age).to be_nil
      expect(foo.weight).to be_nil
      expect(foo.height).to be_nil

      expect(foo).to be_valid
      expect(foo).to_not be_invalid
    end

    it 'properly adds validation for date fields' do
      Foo.class_eval do
        define_id_field
        define_fields :name
        define_fields :birthday, type: :date
      end

      foo = Foo.new id: 2, name: 'Rafael Guerreiro', birthday: '1992/06/09'

      expect(foo.name).to eq('Rafael Guerreiro')
      expect(foo.birthday).to eq(DateTime.new(1992, 6, 9))

      expect(foo).to be_valid
      expect(foo).to_not be_invalid

      foo = Foo.new id: 12,
                    name: 'Rafael Guerreiro',
                    birthday: DateTime.new(1992, 6, 9)

      expect(foo.name).to eq('Rafael Guerreiro')
      expect(foo.birthday).to eq(DateTime.new(1992, 6, 9))

      expect(foo).to be_valid
      expect(foo).to_not be_invalid
    end
  end

  describe '.define_id_field' do
    it 'defines an standard id field' do
      Foo.class_eval { define_id_field }

      foo = Foo.new id: 1
      expect(foo.id).to eq(1)
    end

    it 'allows options to be overriden' do
      Foo.class_eval { define_id_field type: :string }

      foo = Foo.new id: 'VAL01'
      expect(foo.id).to eq('VAL01')
    end
  end
end
