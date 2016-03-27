describe CsvModel::Base do
  before do
    stub_const 'Person', Class.new(CsvModel::Base)
  end

  describe '#valid?' do
    it 'class must respond to :id' do
      expect(Person.new.valid?).to be_falsy
      Person.class_eval do
        def id
          1
        end
      end

      expect(Person.new.valid?).to be_truthy
    end

    it 'iterates over all validable fields to validate the object' do
      Person.class_eval do
        define_id_field
        define_field :name
        define_field :age, type: :numeric, presence: false
      end

      bob = Person.new id: 12, name: 'Bob'
      expect(bob.valid?).to be_truthy

      anna = Person.new name: 'Anna', age: 25
      expect(anna.valid?).to be_falsy

      obj = Person.new id: 3, name: '', age: 20
      expect(obj.valid?).to be_falsy
    end
  end

  describe '#invalid?' do
    it 'class must respond to :id' do
      expect(Person.new.invalid?).to be_truthy
      Person.class_eval do
        def id
          1
        end
      end

      expect(Person.new.invalid?).to be_falsy
    end

    it 'iterates over all validable fields to validate the object' do
      Person.class_eval do
        define_id_field
        define_field :name
        define_field :age, type: :numeric, presence: false
      end

      bob = Person.new id: 12, name: 'Bob'
      expect(bob.invalid?).to be_falsy

      anna = Person.new name: 'Anna', age: 25
      expect(anna.invalid?).to be_truthy

      obj = Person.new id: 3, name: '', age: 20
      expect(obj.invalid?).to be_truthy
    end
  end
end
