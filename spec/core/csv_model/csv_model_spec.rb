describe CsvModel do
  before do
    stub_const 'Foo', Class.new
    Foo.class_eval { include CsvModel }
  end

  describe '.define_field' do
    it 'defines one field with getter and add validity methods' do
      Foo.class_eval { define_field :name }

      foo = Foo.new name: 'Rafael Guerreiro'

      expect(foo.name).to eq('Rafael Guerreiro')
      expect(foo.valid?).to be_truthy
      expect(foo.invalid?).to be_falsy
    end
  end
end
