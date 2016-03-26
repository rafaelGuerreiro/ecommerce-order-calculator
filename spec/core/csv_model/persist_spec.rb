describe CsvModel::Loader do
  before do
    stub_const 'Foo', Class.new(CsvModel::Base)

    Foo.class_eval do
      define_id_field
      define_field :name
      define_field :price, type: :numeric
    end
  end

  describe '.create' do
    it 'instantiates a foo object and persists it in CsvModelRepository' do
      expect(Foo.find(123)).to be_nil

      foo = Foo.create(id: 123, name: 'a name', price: 125)
      expect(Foo.find(123)).to be(foo)
    end
  end

  describe '#save' do
    it 'persists foo in CsvModelRepository' do
      foo = Foo.new(id: 123, name: 'a name', price: 125)

      expect(Foo.find(123)).to be_nil

      foo.save

      expect(Foo.find(123)).to be(foo)
    end
  end
end
