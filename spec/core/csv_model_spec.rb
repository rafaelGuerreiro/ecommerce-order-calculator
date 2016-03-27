describe CsvModel::Base do
  before do
    stub_const 'Person', Class.new(CsvModel::Base)
  end

  describe '#valid?' do
    it 'class must respond to :id' do
      expect(Person.new).to_not be_valid
      Person.class_eval do
        def id
          1
        end
      end

      expect(Person.new).to be_valid
    end

    it 'iterates over all validable fields to validate the object' do
      Person.class_eval do
        define_id_field
        define_field :name
        define_field :age, type: :numeric, presence: false
      end

      bob = Person.new id: 12, name: 'Bob'
      expect(bob).to be_valid

      anna = Person.new name: 'Anna', age: 25
      expect(anna).to_not be_valid

      obj = Person.new id: 3, name: '', age: 20
      expect(obj).to_not be_valid
    end
  end

  describe '#invalid?' do
    it 'class must respond to :id' do
      expect(Person.new).to be_invalid
      Person.class_eval do
        def id
          1
        end
      end

      expect(Person.new).to_not be_invalid
    end

    it 'iterates over all validable fields to validate the object' do
      Person.class_eval do
        define_id_field
        define_field :name
        define_field :age, type: :numeric, presence: false
      end

      bob = Person.new id: 12, name: 'Bob'
      expect(bob).to_not be_invalid

      anna = Person.new name: 'Anna', age: 25
      expect(anna).to be_invalid

      obj = Person.new id: 3, name: '', age: 20
      expect(obj).to be_invalid
    end
  end
end
