describe CsvModel::Base do
  before do
    stub_const 'Foo', Class.new(CsvModel::Base)
  end

  describe '#valid?' do
    it 'class must respond to :id' do
      expect(Foo.new.valid?).to be_falsy
      Foo.class_eval do
        def id
          1
        end
      end

      expect(Foo.new.valid?).to be_truthy
    end

    it 'iterates over all validable fields to validate the object' do
      Foo.class_eval do
        define_id_field
        define_field :name
        define_field :age, type: :numeric, presence: false
      end

      bob = Foo.new id: 12, name: 'Bob'
      expect(bob.valid?).to be_truthy

      anna = Foo.new name: 'Anna', age: 25
      expect(anna.valid?).to be_falsy

      obj = Foo.new id: 3, name: '', age: 20
      expect(obj.valid?).to be_falsy
    end
  end
end
