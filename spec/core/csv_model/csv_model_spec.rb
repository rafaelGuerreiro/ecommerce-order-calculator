describe CsvModel do
  before do
    stub_const 'Foo', Class.new
    Foo.class_eval { include CsvModel }
  end

  describe '.define_field' do
    it 'defines one field with getter and add validity methods' do
      Foo.class_eval { define_field :name }

      foo = Foo.new name: 'Rafael Guerreiro'

      expect(foo.is_a?(CsvModel)).to be_truthy

      expect(foo.name).to eq('Rafael Guerreiro')
      expect(foo.valid?).to be_truthy
      expect(foo.invalid?).to be_falsy
    end

    it 'defines various fields and append them to validity' do
      Foo.class_eval do
        define_field :name
        define_field :age, type: :numeric
      end

      foo = Foo.new name: 'Rafael Guerreiro', age: 23

      expect(foo.name).to eq('Rafael Guerreiro')
      expect(foo.age).to eq(23)
      expect(foo.valid?).to be_truthy
      expect(foo.invalid?).to be_falsy
    end

    it 'properly validates numeric fields' do
      Foo.class_eval { define_field :number, type: :numeric }

      foo = Foo.new number: 55
      expect(foo.number).to eq(55)
      expect(foo.valid?).to be_truthy
      expect(foo.invalid?).to be_falsy

      foo = Foo.new number: 55.5
      expect(foo.number).to eq(55.5)
      expect(foo.valid?).to be_truthy
      expect(foo.invalid?).to be_falsy

      foo = Foo.new number: '55.5'
      expect(foo.number).to eq('55.5')
      expect(foo.valid?).to be_truthy
      expect(foo.invalid?).to be_falsy

      foo = Foo.new number: 'Rafael Guerreiro'
      expect(foo.number).to eq('Rafael Guerreiro')
      expect(foo.valid?).to be_falsy
      expect(foo.invalid?).to be_truthy
    end
  end

  describe '.define_fields' do
    it 'defines various fields with the same properties' do
      Foo.class_eval do
        define_fields :name
        define_fields :age, :weight, :height, type: :numeric, presence: false
      end

      foo = Foo.new name: 'Rafael Guerreiro'

      expect(foo.name).to eq('Rafael Guerreiro')
      expect(foo.age).to be_nil
      expect(foo.weight).to be_nil
      expect(foo.height).to be_nil

      expect(foo.valid?).to be_truthy
      expect(foo.invalid?).to be_falsy
    end
  end
end
